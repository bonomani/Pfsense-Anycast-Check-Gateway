# Pfsense-Anycast-Check-Gateway-Status
- This is a 2nd "raw" release

For Anycast we need to have a check that fires up/down the anycast IP: the principe
- The script monitor a gatway: you need to monitor an IP in the config
- The script use OSPF for the anycast and manipulate the configuration of FRR routing via vtysh
    - Enable/Disable the loopback to be in the ospf area 
- The script check that it is not already running
- The script run forever every 10 sec 

You should have
- Add a loopback with the anycast address (I also have a second ip to monitor the anycast) 
- The anycast service should be attached to this ip address

Many improvement can be done, suggest yours!

1. Install both files (with the filer package)
   - See instructions in the files and adapt your config
2. To do manually 
   - Edit (vi) /conf/config.xml 
   - To add the following, in the service section
```
		<service>
			<name>Anycast ctrld</name>
			<rcfile>anycast_ctrld</rcfile>
			<executable>anycast_ctrld</executable>
			<description><![CDATA[Anycast gatewaystatus ctrld]]></description>
		</service>
```
3. Reboot
4. Start the service in the  service section
5. Look at the log and at th routing to see the changes

