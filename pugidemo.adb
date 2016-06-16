-- pugidemo.adb - Tue Jun 14 23:26:10 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999
--
-- Simple pugixml_ada demo program:
--
--    1. Create sample testconfig.xml
--    2. Load and digest testconfig.xml

with Pugi_Xml;
with Ada.Text_IO;

procedure PugiDemo is
   use Ada.Text_IO, Pugi_Xml;
begin

   -------------------------------------------------------------------
   -- Generate a testconfig.xml file
   -------------------------------------------------------------------

   declare
      Document:   XML_Document;
      Root:       XML_Node := Document.Root;
      Config:     XML_Node;
      Ifaces:     XML_Node;
      Iface:      XML_Node;
      Params:     XML_Node;
      Attr:       XML_Attribute;
      OK:         Boolean;
   begin
      Config := Root.Append_Child("config");
      Ifaces := Config.Append_Child("interfaces");

      Iface := Ifaces.Append_Child("interface");

      Attr := Iface.Append_Attribute("address");
      OK := Attr.Set_Value("8.8.8.8");
      pragma Assert(OK);

      Attr := Iface.Append_Attribute("port");
      OK := Attr.Set_Value(Standard.Integer'(80));
      pragma Assert(OK);

      Attr := Iface.Append_Attribute("backlog");
      OK := Attr.Set_Value(Standard.Integer'(500));
      pragma Assert(OK);

      Iface := Ifaces.Append_Child("interface");

      Attr := Iface.Append_Attribute("address");
      OK := Attr.Set_Value("8.8.8.9");
      pragma Assert(OK);

      Attr := Iface.Append_Attribute("port");
      OK := Attr.Set_Value(Standard.Integer'(80));
      pragma Assert(OK);

      Attr := Iface.Append_Attribute("backlog");
      OK := Attr.Set_Value(Standard.Integer'(750));
      pragma Assert(OK);

      Params := Config.Append_Child("database");

      Attr := Params.Append_Attribute("host");
      OK := Attr.Set_Value("10.0.50.99");
      pragma Assert(OK);
   
      Attr := Params.Append_Attribute("port");
      OK := Attr.Set_Value(Standard.Integer'(3306));
      pragma Assert(OK);
   
      Attr := Params.Append_Attribute("user");
      OK := Attr.Set_Value("admin");
      pragma Assert(OK);
   
      Attr := Params.Append_Attribute("password");
      OK := Attr.Set_Value("knarf!");
      pragma Assert(OK);

      Document.Save("testconfig.xml",OK,"    ");
      pragma Assert(OK);
      Put_Line("XML file testconfig.xml saved.");
   end;

   -------------------------------------------------------------------
   -- Load a testconfig.xml file
   -------------------------------------------------------------------

   declare
      Document:   XML_Document;
      Result:     XML_Parse_Result;
      Root:       XML_Node := Document.Root;
      Config, Ifaces, Iface: XML_Node;
      Attr:       XML_Attribute;
   begin
      Document.Load("testconfig.xml",Result => Result);
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

end PugiDemo;

-- End pugidemo.adb
