//
//  GatewayFinder.h
//  CrossPlatformCommunicator
//
//  Created by MARS Lab on 7/17/17.
//  Copyright © 2017 MARS Lab. All rights reserved.
//

#ifndef GatewayFinder_h
#define GatewayFinder_h

#include <stdio.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <string.h>
#include <arpa/inet.h>
#import "route.h"

char* routerIP();
int getdefaultgateway(in_addr_t * addr);

#endif /* GatewayFinder_h */
