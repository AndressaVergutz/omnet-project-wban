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

import inet.networklayer.autorouting.ipv4.IPv4NetworkConfigurator;
import inet.world.radio.ChannelControl;
import inet.examples.wpan.csma802154.nodecsma802154;


network csma802154net
{
    parameters:
        int numFixHosts;
        double nodeSeparation @unit("m")=default (40m);
    submodules:
        fixhost[numFixHosts]: nodecsma802154 {
            parameters:
              y =  (floor(index/sqrt(numFixHosts))*nodeSeparation)+(nodeSeparation);
              x = ((index%floor(sqrt(numFixHosts)))*nodeSeparation)+(nodeSeparation);
              @display("i=device/pocketpc_s;r=,,#707070");
        }
        channelControl: ChannelControl {
            parameters:
                @display("p=60,50;i=misc/sun");
        }
        configurator: IPv4NetworkConfigurator {
            config=xml("<config><interface hosts='*' address='145.236.x.x' netmask='255.255.0.0'/></config>");
            @display("p=140,50");
        }
    connections allowunconnected:
}


