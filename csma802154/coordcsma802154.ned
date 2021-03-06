//
// Copyright (C) 2008 Feng Chen
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
//

package inet.examples.wpan.csma802154;

import inet.applications.IPingApp;
import inet.applications.ITCPApp;
import inet.applications.IUDPApp;
import inet.base.NotificationBoard;
import inet.battery.IBattery;
import inet.linklayer.loopback.LoopbackInterface;
import inet.mobility.static.StationaryMobility;
import inet.networklayer.IManetRouting;
import inet.networklayer.common.InterfaceTable;
import inet.networklayer.ipv4.RoutingTable;
import inet.nodes.inet.NetworkLayer;
import inet.transport.IUDP;
import inet.transport.tcp.TCP;
import inet.wpan.Isabel.Base.Display;
import inet.wpan.linklayer.ieee802154.Ieee802154csmaNic;


//
// Models a mobile host with a wireless (802.11b) card. This module is
// a WirelessHost less the \PPP and Ethernet interfaces, plus mobility
// support (BasicMobility). It is intended mainly for mobile ad-hoc
// networks.
//
module coordcsma802154
{
    parameters:
        @node();
        // int typeNode = default(1);
        int numTcpApps = default(0);
        int numUdpApps = default(0);
        int numPingApps = default(0);  // no of PING apps. Specify the app types in INI file with pingApp[0..1].typename="PingApp" syntax       
        int x @unit("m");
        int y @unit("m");
        string tcpAppType = default("");
        string udpAppType = default("");
        string udpType = default(firstAvailable("UDP","UDP_None"));

        string routingFile = default("");
        string routingProtocol @enum("AODVUU","DYMOUM","DYMO","DSRUU","OLSR","OLSR_ETX","DSDV_2","Batman") = default("");  // used mobile routing protocol. see: inet.networklayer.manetrouting
        string batteryModel @enum("InetSimpleBattery","BasicBattery","") = default("InetSimpleBattery");  // used mobile routing protocol. see: inet.networklayer.manetrouting
        @display("i=device/pocketpc_s");

    gates:
        input radioIn @directIn;

    submodules:
        notificationBoard: NotificationBoard {
            parameters:
                @display("p=60,70;i=block/control");
        }
        interfaceTable: InterfaceTable {
            parameters:
                @display("p=60,150;i=block/table");
        }
        routingTable: RoutingTable {
            parameters:
                //IPForward = IPForward,
                IPForward = true;
                routerId = "";
                routingFile = routingFile; 			//no routerFile tb lê um arquivo de roteamento
                @display("p=60,230;i=block/table");
        }
        tcpApp[numTcpApps]: <tcpAppType> like ITCPApp {
            parameters:
                @display("p=163,67;i=block/app");
        }
        tcp: TCP {
            parameters:
                @display("p=163,154;i=block/wheelbarrow");
        }
        udpApp[numUdpApps]: <> like IUDPApp {
            parameters:
                @display("i=block/app;p=272,67");
        }
        udp: <udpType> like IUDP {
            //    udp: UDP {
            parameters:
                @display("p=272,154;i=block/transport");
        }
        pingApp[numPingApps]: <default("PingApp")> like IPingApp {
            parameters:
                @display("p=501,230");
        }
       // queue[sizeof(out)]: FifoQueue {
         //   @display("p=410,150,c");
           // buffer_length = bufferSize;
        //}

        //router: FileRouter {
         //   @display("p=371,230");
            //  routingFile = routingFile;
        // }
        networkLayer: NetworkLayer {
            parameters:
                proxyARP = false;
                arp.globalARP = true;
                @display("p=248,247;i=block/fork;q=queue");
            gates:
                ifIn[1];
                ifOut[1];
        }
        manetrouting: <routingProtocol> like IManetRouting if routingProtocol != "" {
            @display("p=159,287");
        }

        lo0: LoopbackInterface {
            @display("p=209,368");
        }

        // the name of radio interface must have "wlan", valid examples wlan, wlan802, localwlan ....
        wlan: Ieee802154csmaNic {
            parameters:
                @display("p=287,357;q=queue");
        }
        //        wlan: Nic80211;
        //            display: "p=248,349;q=queue;i=block/ifcard";
        mobility: StationaryMobility {
            parameters:
                initialX = x;
                initialY = y;
                initFromDisplayString = false;
                @display("p=152,368;i=block/cogwheel");
        }
        disp: Display {
            parameters:
                @display("p=65,379;i=block/app2");

        }
        // battery module
        battery: <batteryModel> like IBattery if batteryModel != "" {
            parameters:
                @display("p=65,310;i=block/plug");

        }
    connections allowunconnected:

        networkLayer.ifOut++ --> lo0.upperLayerIn;
        lo0.upperLayerOut --> networkLayer.ifIn++;

       // for i=0..numTcpApps-1 {
        //    tcpApp[i].tcpOut --> tcp.appIn++;
        //    tcpApp[i].tcpIn <-- tcp.appOut++;
       // }

       // tcp.ipOut --> networkLayer.transportIn++;
      //  tcp.ipIn <-- networkLayer.transportOut++;

        for i=0..numUdpApps-1 {
            udpApp[i].udpOut --> udp.appIn++;
            udpApp[i].udpIn <-- udp.appOut++;
        }

        udp.ipOut --> networkLayer.transportIn++;
        udp.ipIn <-- networkLayer.transportOut++;

        //for i=0..numPingApps-1 {
       //     networkLayer.pingOut++ --> pingApp[i].pingIn;
      //      networkLayer.pingIn++ <-- pingApp[i].pingOut;
      //  }


        networkLayer.transportOut++ --> manetrouting.from_ip if routingProtocol != "";
        networkLayer.transportIn++ <-- manetrouting.to_ip if routingProtocol != "";
        // connections to network outside
        radioIn --> wlan.radioIn;
        wlan.upperLayerOut --> networkLayer.ifIn++;
        wlan.upperLayerIn <-- networkLayer.ifOut++;
}

