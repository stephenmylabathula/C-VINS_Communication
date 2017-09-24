package com.smylabathulagoogle.crossplatformcommunicator;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import java.io.*;
import java.net.*;
import com.google.gson.*;


public class MainActivity extends AppCompatActivity implements Runnable {

    EditText txtMessage, txtReceive;
    Button btnListen;
    Thread sender, receiver, listener, closer;
    ServerSocket server;
    Socket socket;
    InputStream inputStream;
    OutputStream outputStream;
    PrintWriter outWriter;
    float[] dataToSend = {1.334f, 2.546f, 3.557f};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        txtMessage = (EditText) findViewById(R.id.editTextMessage);
        txtReceive = (EditText) findViewById(R.id.editTextReceiveMessage);
        btnListen = (Button) findViewById(R.id.buttonListen);
        sender = new Thread(this);
        receiver = new Thread(this);
        listener = new Thread(this);
        closer = new Thread(this);
    }

    @Override
    public void run() {
        if (Thread.currentThread().equals(listener)){
            try{
                server = new ServerSocket(12345);   //Start listening
                socket = server.accept();   //Wait (Block) until someone connects
                runOnUiThread(new Runnable(){
                    @Override
                    public void run(){
                        btnListen.setText("Connected");
                        btnListen.setClickable(false);
                    }
                });
                socket.setSoTimeout(5000);  //Only block for 5 seconds when waiting to read input
                inputStream = socket.getInputStream();
                outputStream = socket.getOutputStream();
                outWriter = new PrintWriter(outputStream, true);
            } catch (IOException e){
                e.printStackTrace();
            }
        } else if(Thread.currentThread().equals(sender) && outWriter != null){
            String messageStr = txtMessage.getText().toString();
            String dataString = new Gson().toJson(dataToSend);
            byte[] dataBytes = dataString.getBytes();
            try {
                outputStream.write(dataBytes);
            } catch (IOException e) {
                e.printStackTrace();
            }
            //outWriter.println(dataString); //messageStr
        } else if(Thread.currentThread().equals(receiver) && inputStream != null){
            try{
                byte[] b = new byte[1024];
                inputStream.read(b);
                final String msg = new String(b);
                runOnUiThread(new Runnable(){
                    @Override
                    public void run(){
                        txtReceive.setText(msg);
                    }
                });
            } catch (IOException e){
                e.printStackTrace();
            }
        } else if(Thread.currentThread().equals(closer) && socket != null){
            try{
                outWriter.close();
                inputStream.close();
                outputStream.close();
                socket.close();
                server.close();
                this.finishAndRemoveTask();
            } catch (IOException e){
                e.printStackTrace();
            }
        }
    }

    void listen(View view){
        listener.start();
    }

    void close(View view){
        closer.start();
    }

    void receiveMessage(View view){
        receiver.start();
    }

    void sendMessage(View view) {
        sender.start();
    }

}
