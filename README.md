# Pfsense-Anycast-Check-Gateway-Status
- This is a 3nd "raw" release

Last update 9.02.2024
- Improve start and stop, add all logic, but nothing really new: just very clean (to be be a good base for improvement)

For Anycast we need to have a check that fires up/down the anycast IP: the principe
- The script monitor the gateway on the a defined interface: (see variables in the script)
- The script use OSPF for the anycast and manipulate the configuration of FRR routing via vtysh
    - Enable/Disable ospf on the loopback to be in the ospf area 
- The script check that it is not already running
- The script run forever 

You should have
- Add a loopback with the anycast address (I also have a second ip taht is not anycast to monitor that if this check if fired or not) 
- The anycast service should be attached to this ip address

Many improvement can be done, suggest yours!

1. Install both files (with the filer package)
   - See instructions in the files and adapt your config
2. Manual change (make a copy of the file, backup your config)
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
3. Reboot (so it take the conf change!
4. Start the service in the service section (manually to show if it works)
5. Look at the log and at the FRR routing to see the changes
6. Statrt automatically at boor
   - With sshcmd package (add "anycast_ctrld start"), package need to be installed (RECOMMENDED)
   - Or you can use use the watchdog service (need to be installed) to make it restart automatically (if it stop, but dont not forget to remove it if you want to really stop it) (NOT RECOMMENDED)
