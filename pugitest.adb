-- pugitest.adb - Fri Jun 10 22:20:07 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Pugi_Xml, Interfaces.C;
use Pugi_Xml;

with Ada.Text_IO;

procedure PugiTest is
   use Ada.Text_IO;

   Doc:  XML_Document;
   Res:  XML_Parse_Result;
   Node: Xml_Node;
   Gnat_Prep: Xml_Node;
   Par_Node: Xml_Node;
begin

   pragma Assert(Node.Is_Null);

   Put_Line("Running");
   Load(Doc,"pugitest.xml",Res);
   Put("Load Results: Status: ");
   Put(XML_Parse_Status'Image(Status(Res)));
   Put(" Offset: ");
   Put(Interfaces.C.Unsigned'Image(Offset(Res)));
   Put(" Encoding: ");
   Put(XML_Encoding'Image(Encoding(Res)));
   Put(" OK: ");
   Put(Boolean'Image(OK(Res)));
   Put(" Description: ");
   Put_Line(Description(Res));

   Put_Line("Getting Child");
   Node := Doc.Child("entities");
   Put("Node name is '");
   Put(Node.Name);
   Put_Line("', Type=" & XML_Node_Type'Image(Node.Node_Type));

   Gnat_Prep := Node.Child("gnatprep");
   Put_Line("Gnat_Prep name is '" & Gnat_Prep.Name & "'");

   declare
      F, L: XML_Attribute;
   begin
      F := Gnat_Prep.First_Attribute;
      L := Gnat_Prep.Last_Attribute;
      Put_Line("gnatprep First attr " & F.Name & " and last attr " & L.Name);
      Put_Line("Values are '" & F.Value & "' and '" & L.Value & "'");
   end;

   pragma Assert(Node.Empty = False);

   Gnat_Prep := Node.Child("gnatprep");
   Put("Gnat_Prep name is '");
   Put(Gnat_Prep.Name);
   Put_Line("'");

   pragma Assert(Gnat_Prep = Gnat_Prep);
   declare
      Other : XML_Node := Node.Child("gnatprep");
   begin
      pragma Assert(Gnat_Prep = Gnat_Prep);
      pragma Assert(Gnat_Prep /= Other);
      pragma Assert(Other /= Par_Node);
   end;

   declare
      V : String := Gnat_Prep.Value;
   begin
      Put("Value='");
      Put(V);
      Put_line("'");
   end;

   declare
      First, Last, Temp : XML_Node;
   begin
      First := Gnat_Prep.First_Child;
      Last := Gnat_Prep.Last_Child;
      Put("First and last child of Gnat_Prep are ");
      Put(First.Name);
      Put(" and ");
      Put_Line(Last.Name);

      Put_Line("All Siblings are:");
      Temp := First;
      loop
         Put_Line(Temp.Name);
         Temp := Temp.Next;
         exit when Temp.Is_Null;
      end loop;
      Put_Line("--");

      Put_Line("All Siblings in Reverse Order:");
      Temp := Last;
      loop
         Put_Line(Temp.Name);
         Temp := Temp.Previous;
         exit when Temp.Is_Null;
      end loop;
      Put_Line("--");

      declare
         Middle : String := First.Child_Value;
      begin
         Put_Line("Child value is '" & Middle & "'");
      end;

      declare
         Middle : String := Gnat_Prep.Child_Value("Middle");
         M : XML_Node := Gnat_Prep.Child("Middle");
      begin
         Put_Line("Child value('Middle') is '" & Middle & "'");
         declare
            Mid2 : String := M.Text;
         begin
         pragma Assert(Mid2 = Middle);
         end;
      end;
   end;

   Par_Node := Parent(Gnat_Prep);
   Put("Parent name is '");
   Put(Par_Node.Name);
   Put_Line("'");

   declare
      Root : XML_Node;
      Temp : XML_Node;
   begin
      Root := Gnat_Prep.Root;
      Temp := Root.First_Child;
      pragma Assert(Temp.Name = "entities");
      Put_Line("Root passed.");
   end;

   declare
      Attr : XML_Attribute;
   begin
      Attr := Gnat_Prep.First_Attribute;
      loop
         Put("Attribute: ");
         Put_Line(Attr.Name);
         Attr := Attr.Next;
         exit when Attr.Is_Null;
      end loop;

      Put_Line("In Reverse Order:");
      Attr := Gnat_Prep.Last_Attribute;
      loop
         Put("Attribute: ");
         Put_Line(Attr.Name);
         Attr := Attr.Previous;
         exit when Attr.Is_Null;
      end loop;
   end;

   declare
      Root : XML_Node := Doc.Root;
      Temp : XML_Node;
      A1, A2, A3, A4: XML_Attribute;
   begin
      Temp := Root.First_Child;
      pragma Assert(Temp.Name = "entities");
      Put_Line("As_Node passed.");

      A4 := Temp.Append_Attribute("A4");
      A1 := Temp.Prepend_Attribute("A1");
      A2 := Temp.Insert_Attribute_After("A2",A1);
      A3 := Temp.Insert_Attribute_Before("A3",A4);
   end;

   Put_Line("Testing document creation:");

   declare
      New_Doc : XML_Document;
      Root : XML_Node := New_Doc.Root;
      Node : XML_Node;
      Attr1 : XML_Attribute;
   begin
      Node := Root.Append_Child("Named_Root");
      pragma Assert(Node.Name = "Named_Root");
      Put_Line("New Document Test passed.");
   end;

   declare
      New_Doc : XML_Document;
      Root, Node : XML_Node;
      Attr1 : XML_Attribute;
      OK : Boolean;
   begin
      Root := New_Doc.Root;
      Node := Root.Append_Child("Node");
      pragma Assert(Node.Is_Null = False);
      Attr1 := Node.Append_Attribute("Attr1");
      OK := Attr1.Set_Value("ATTR_ONE");
      pragma Assert(OK);
      pragma Assert(Attr1.Is_Null = False);
      Save(New_Doc,"out.xml",OK);
      pragma assert(OK);
      Put_Line("Saved as out.xml");
   end;

   declare
      First, Two, Last: XML_Attribute;
   begin
      First := Gnat_Prep.First_Attribute;
      Two := Gnat_Prep.Attribute("attr2");
      Last := Gnat_Prep.Last_Attribute;

      Put_Line("attr1.name = " & First.Name);
      Put_Line("attr2.name = " & Two.Name);
      Put_Line("attr3.name = " & Last.Name);

      pragma Assert(First.Name = "attr1");
      pragma Assert(Two.Name = "attr2");
      pragma Assert(Last.Name = "attr3");

      pragma Assert(First.Value = "One");
      pragma Assert(Two.Value = "Two");
      pragma Assert(Last.Value = "Three");

      pragma Assert(First.Empty = False);
      pragma Assert(Two.Empty = False);
      pragma Assert(Last.Empty = False);

      Put_Line("Attributes passed.");
   end;

   declare
      Content: aliased String := "<Root_Node><Node1 Attr1=""One"" /></Root_Node>";
      Doc: XML_Document;
      Res: XML_Parse_Result;
      Root, Root_Node, Node1: XML_Node;
      Attr1 : XML_Attribute;
   begin
      Doc.Load_In_Place(Content(1)'Address,Content'Length,Result=>Res);
      pragma Assert(Res.OK = True);
      Root := Doc.Root;
      Root_Node := Root.Child("Root_Node");
      Put_Line("Root Node name is '" & Root_Node.Name & "'");
      pragma Assert(Root_Node.Name = "Root_Node");
      Node1 := Root_Node.Child("Node1");
      Put_Line("Node1 name is '" & Node1.Name & "'");
      pragma Assert(Node1.Name = "Node1");
      Attr1 := Node1.Attribute("Attr1");
      pragma Assert(Attr1.Name = "Attr1");
      pragma Assert(Attr1.Value = "One");

      Put("Node1.Attr1=""");
      Put(Attr1.Value);
      Put_Line("""");

      Put_Line("Load_In_Place verified.");
   end;

   Put_Line("Done");

end PugiTest;
