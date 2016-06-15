# pugixml_ada
A thick Ada Binding for the pugi::xml C++ library.

The included demo program pugidemo.adb, generates this 
simple XML file:

    <?xml version="1.0"?>
    <config>
        <interfaces>
            <interface address="8.8.8.8" port="80" backlog="500" />
            <interface address="8.8.8.9" port="80" backlog="750" />
        </interfaces>
        <database host="10.0.50.99" port="3306" user="admin" password="knarf!" />
    </config>

The demo code (in pugidemo.adb) loads this information:

    declare
       Document:   XML_Document;
       Result:     XML_Parse_Result;
       Root:       XML_Node := Document.Root;
       Config, Ifaces, Iface: XML_Node;
       Attr:       XML_Attribute;
    begin
       Document.Load("testconfig.xml",Result);
       if not Result.OK then
          Put(Result.Description);
          Put(": testconfig.xml parse status ");
          Put(XML_Parse_Status'Image(Result.Status));
          Put(" at offset ");
          Put_Line(Natural'Image(Result.Offset));
       end if;
       pragma Assert(Result.OK = True);
 
       Root := Document.Root;
       Config := Root.Child("config");
       pragma Assert(not Config.Is_Null);
 
       Ifaces := Config.Child("interfaces");
       pragma Assert(not Ifaces.Is_Null);
 
       Put_Line("CONFIGURED INTERFACES:");
 
       Iface := Ifaces.First_Child;
       pragma Assert(not Iface.Is_Null);
       
       while not Iface.Is_Null loop
          declare
             IP_Address : String := Iface.Attribute("address").Value;
             Port :       Natural := Natural(Iface.Attribute("port").As_Uint);
             Backlog :    Natural := Natural(Iface.Attribute("backlog").As_Uint);
          begin
             Put("  IP_Address: ");
             Put(IP_Address);
             Put(" Port:");
             Put(Natural'Image(Port));
             Put(" Backlog:");
             Put_Line(Natural'Image(Backlog));
          end;
 
          Iface := Iface.Next;
       end loop;
 
       Put_Line("DATABASE:");
       declare
          Database:   XML_Node;
       begin
          Database := Config.Child("database");
          Put("  Host:     ");
          Put_Line(Database.Attribute("host").Value);
          Put("  Port:    ");
          Put_Line(Natural'Image(Natural(Database.Attribute("port").As_Uint)));
          Put("  User:     ");
          Put_Line(Database.Attribute("user").Value);
          Put("  Password: ");
          Put_Line(Database.Attribute("password").Value);
       end;
    end;
