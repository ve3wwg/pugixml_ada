-- pugi_xml.adb - Fri Jun 10 21:55:55 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

-- with Ada.Text_IO;

package body Pugi_Xml is

   function Strlen(C_Ptr : System.Address) return Natural is
      function UX_strlen(cstr : System.Address) return Interfaces.C.Unsigned;
      pragma Import(C,UX_strlen,"c_strlen");
   begin
      return Natural(UX_strlen(C_Ptr));
   end Strlen;

   function C_String(Ada_String: String) return String is
      T : String(Ada_String'First..Ada_String'Last+1);
   begin
      T(T'First..T'Last-1) := Ada_String;
      T(T'Last) := Character'Val(0);
      return T;
   end C_String;

--   function Ada_String(C_String: String) return String is
--   begin
--      for X in C_String'Range loop
--         if Character'Pos(C_String(X)) = 0 then
--            return C_String(C_String'First..X-1);
--         end if;
--      end loop;
--      return C_String;
--   end Ada_String;
--
--   function Ada_String(C_String: uchar_array) return String is
--      C : constant String(1..C_String'Length) := To_String(C_String);
--   begin
--      return Ada_String(C);
--   end Ada_String;
--
--   function Ada_String(C_String: System.Address) return String is
--      use System;
--   begin
--      if C_String = Null_Address then
--         return "";
--      end if;
--
--      declare
--         Len : constant Natural := Strlen(C_String);
--         Str : String(1..Len);
--         for Str'Address use C_String;
--      begin
--         return Str;
--      end;
--
--   end Ada_String;

   procedure Initialize(Obj: in out Xml_Document) is
      function new_xml_document return System.Address;
      pragma Import(C,new_xml_document,"pugi_new_xml_document");
   begin
      Obj.Doc := new_xml_document;
   end Initialize;

   procedure Finalize(Obj: in out Xml_Document) is
      procedure delete_xml_document(Doc: System.Address);
      pragma Import(C,delete_xml_document,"pugi_delete_xml_document");
   begin
      delete_xml_document(Obj.Doc);
      Obj.Doc := System.Null_Address;
   end Finalize;

   procedure Initialize(Obj: in out Xml_Node) is
   begin
      Obj.Node := System.Null_Address;
   end Initialize;

   procedure Finalize(Obj: in out Xml_Node) is
   begin
      Obj.Node := System.Null_Address;   
   end Finalize;

   procedure Initialize(Obj: in out Xml_Attribute) is
   begin
      Obj.Attr := System.Null_Address;
   end Initialize;

   procedure Finalize(Obj: in out Xml_Attribute) is
   begin
      Obj.Attr := System.Null_Address;   
   end Finalize;

   procedure As_Root(Obj: XML_Document; Node: out XML_Node'Class) is
      function root(Doc: System.Address) return System.Address;
      pragma Import(C,root,"pugi_doc_root");
   begin
      Node.Node := root(Obj.Doc);
   end As_Root;

   procedure Load(Obj: XML_Document; Pathname: in String; Result: out XML_Parse_Result'Class) is
      procedure load_xml_file(Doc, Path, Status, Offset, Encoding, OK, C_Desc: System.Address);
      pragma Import(C,load_xml_file,"pugi_load_xml_file");
      C_Path:  aliased String := C_String(Pathname);
      Status:  aliased Standard.Integer;
      Offset:  aliased Interfaces.C.Unsigned;
      Encoding: aliased Standard.Integer;
      OK: aliased Standard.Integer;
      C_Desc:  aliased System.Address;
   begin
      load_xml_file(Obj.Doc,C_Path'Address,Status'Address,Offset'Address,Encoding'Address,OK'Address,C_Desc'Address);
      Result.Status := XML_Parse_Status'Val(Status);
      Result.Offset := Offset;
      Result.Encoding := XML_Encoding'Val(Encoding);
      Result.OK := OK /= 0;
      Result.C_Desc := C_Desc;
   end Load;

   procedure Load_In_Place(Obj: XML_Document; Contents: System.Address; Bytes: Standard.Integer; Encoding: XML_Encoding := Encoding_Auto; Result: out XML_Parse_Result'Class) is
      procedure load_in_place(Obj, Contents, Status, Offset, Enc, OK, C_Desc: System.Address; Size, Encoding: Standard.Integer);
      pragma Import(C,load_in_place,"pugi_load_in_place");
      Status:  aliased Standard.Integer;
      Offset:  aliased Interfaces.C.Unsigned;
      Enc: aliased Standard.Integer;
      OK: aliased Standard.Integer;
      C_Desc:  aliased System.Address;
   begin
      load_in_place(
         Obj      => Obj.Doc,
         Contents => Contents,
         Status   => Status'Address,
         Offset   => Offset'Address,
         Enc      => Enc'Address,
         OK       => OK'Address,
         C_Desc   => C_Desc'Address,
         Size     => Bytes,
         Encoding => XML_Encoding'Pos(Encoding)
      );
      Result.Status := XML_Parse_Status'Val(Status);
      Result.Offset := Offset;
      Result.Encoding := XML_Encoding'Val(Enc);
      Result.OK := OK /= 0;
      Result.C_Desc := C_Desc;
   end Load_In_Place;

   procedure Save(Obj: XML_Document; Pathname: String; OK: out Boolean; Indent: String := Indent_Default; Encoding: XML_Encoding := Encoding_Auto) is
      function save(Doc, Path, Indent: System.Address; Encoding: Standard.Integer) return Standard.Integer;
      pragma Import(C,save,"pugi_save_file");
      C_Path:  aliased String := C_String(Pathname);
      C_Indent: aliased String := C_String(Indent);
   begin
      OK := save(Obj.Doc,C_Path'Address,C_Indent'Address,XML_Encoding'Pos(Encoding)) /= 0;
   end Save;

   procedure Child(Obj: XML_Document; Name: String; Node: out XML_Node'Class) is
      function xml_child(Doc: System.Address; Name: System.Address) return System.Address;
      pragma Import(C,xml_child,"pugi_xml_child");
      C_Name:  aliased String := C_String(Name);
   begin
      Node.Node := xml_child(Obj.Doc,C_Name'Address);
   end Child;

   procedure Reset(Obj: XML_Document) is
      procedure reset(Doc: System.Address);
      pragma Import(C,reset,"pugi_reset");
   begin
      reset(Obj.Doc);
   end Reset;

   procedure Reset(Obj: XML_Document; Proto: XML_Document'Class) is
      procedure reset(Doc, Proto: System.Address);
      pragma Import(C,reset,"pugi_reset_proto");
   begin
      reset(Obj.Doc,Proto.Doc);
   end Reset;

   procedure Child(Obj: XML_Node; Name: String; Node: out XML_Node'Class) is
      function xml_child(Doc: System.Address; Name: System.Address) return System.Address;
      pragma Import(C,xml_child,"pugi_node_child");
      C_Name:  aliased String := C_String(Name);
   begin
      Node.Node := xml_child(Obj.Node,C_Name'Address);
   end Child;

   function Name(Obj: XML_Node) return String is
      function node_name(Node: System.Address) return System.Address;
      pragma Import(C,node_name,"pugi_node_name");
      C_Str :  constant System.Address := node_name(Obj.Node);
      Len :    constant Natural := Strlen(C_Str);
      Name :   String(1..Len);
      for Name'Address use C_Str;
   begin
      return Name;
   end Name;

   procedure Parent(Obj: XML_Node; Node: out XML_Node'Class) is
      function xml_parent(Node: System.Address) return System.Address;
      pragma Import(C,xml_parent,"pugi_xml_parent");
   begin
      Node.Node := xml_parent(Obj.Node);
   end Parent;

   function Empty(Obj: XML_Node) return Boolean is
      function xml_node_empty(Node: System.Address) return Standard.Integer;
      pragma Import(C,xml_node_empty,"pugi_node_empty");
   begin
      return xml_node_empty(Obj'Address) /= 0;
   end Empty;

   function Node_Type(Obj: XML_Node) return XML_Node_Type is
      function get_xml_node_type(Node: System.Address) return Standard.Integer;
      pragma Import(C,get_xml_node_type,"pugi_node_type");
   begin
      return XML_Node_Type'Val(get_xml_node_type(Obj.Node));
   end Node_Type;   

   function Value(Obj: XML_Node) return String is
      function node_value(Node: System.Address) return System.Address;
      pragma Import(C,node_value,"pugi_node_value");
      C_Str :  constant System.Address := node_value(Obj.Node);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Value;

   procedure First_Child(Obj: XML_Node; Node: out XML_Node) is
      function get_first_child(Node: System.Address) return System.Address;
      pragma Import(C,get_first_child,"pugi_first_child");
   begin
      Node.Node := get_first_child(Obj.Node);
   end First_Child;

   procedure Last_Child(Obj: XML_Node; Node: out XML_Node) is
      function get_last_child(Node: System.Address) return System.Address;
      pragma Import(C,get_last_child,"pugi_last_child");
   begin
      Node.Node := get_last_child(Obj.Node);
   end Last_Child;

   procedure Root_Node(Obj: XML_Node; Node: out XML_Node) is
      function get_root_node(Node: System.Address) return System.Address;
      pragma Import(C,get_root_node,"pugi_root_node");
   begin
      Node.Node := get_root_node(Obj.Node);
   end Root_Node;

   procedure Next_Sibling(Obj: XML_Node; Node: out XML_Node) is
      function get_next_sibling(Node: System.Address) return System.Address;
      pragma Import(C,get_next_sibling,"pugi_next_sibling");
   begin
      Node.Node := get_next_sibling(Obj.Node);
   end Next_Sibling;

   procedure Next_Sibling(Obj: XML_Node; Name: String; Node: out XML_Node) is
      function get_next_sibling(Node, Name: System.Address) return System.Address;
      pragma Import(C,get_next_sibling,"pugi_next_named_sibling");
      C_Name:  aliased String := C_String(Name);
   begin
      Node.Node := get_next_sibling(Obj.Node,C_Name'Address);
   end Next_Sibling;

   procedure Previous_Sibling(Obj: XML_Node; Node: out XML_Node) is
      function get_prev_sibling(Node: System.Address) return System.Address;
      pragma Import(C,get_prev_sibling,"pugi_prev_sibling");
   begin
      Node.Node := get_prev_sibling(Obj.Node);
   end Previous_Sibling;

   procedure Previous_Sibling(Obj: XML_Node; Name: String; Node: out XML_Node) is
      function get_prev_sibling(Node, Name: System.Address) return System.Address;
      pragma Import(C,get_prev_sibling,"pugi_prev_named_sibling");
      C_Name:  aliased String := C_String(Name);
   begin
      Node.Node := get_prev_sibling(Obj.Node,C_Name'Address);
   end Previous_Sibling;

   function Is_Null(Obj: XML_Node) return Boolean is
      Node_Info : XML_Node_Type := Node_Type(Obj);
   begin
      return Node_Info = Node_Null;
   end Is_Null;

   function Child_Value(Obj: XML_Node) return String is
      function child_value(Node: System.Address) return System.Address;
      pragma Import(C,child_value,"pugi_child_value");
      C_Str :  constant System.Address := child_value(Obj.Node);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Child_Value;

   function Child_Value(Obj: XML_Node; Name: String) return String is
      function child_value(Node: System.Address; Name: System.Address) return System.Address;
      pragma Import(C,child_value,"pugi_named_child_value");
      C_Name:  aliased String := C_String(Name);
      C_Str :  constant System.Address := child_value(Obj.Node,C_Name'Address);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Child_Value;

   procedure Set_Name(Obj: XML_Node; Data: String; OK: out Boolean) is
      function set_name(Node, Data: System.Address) return Standard.Integer;
      pragma Import(C,set_name,"pugi_set_name");
      C_Data: aliased String := C_String(Data);
   begin
      OK := set_name(Obj.Node,C_Data'Address) /= 0;
   end Set_Name;

   procedure Set_Value(Obj: XML_Node; Data: String; OK: out Boolean) is
      function set_value(Node, Data: System.Address) return Standard.Integer;
      pragma Import(C,set_value,"pugi_set_value");
      C_Data: aliased String := C_String(Data);
   begin
      OK := set_value(Obj.Node,C_Data'Address) /= 0;
   end Set_Value;

   function "="(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_eq(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_eq,"pugi_is_eq");
   begin
      return is_eq(Left.Node'Address,Right.Node'Address) /= 0;
   end "=";

   function "<"(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_lt(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_lt,"pugi_is_lt");
   begin
      return is_lt(Left.Node'Address,Right.Node'Address) /= 0;
   end "<";

   function "<="(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_le(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_le,"pugi_is_le");
   begin
      return is_le(Left.Node'Address,Right.Node'Address) /= 0;
   end "<=";

   function ">"(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_gt(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_gt,"pugi_is_gt");
   begin
      return is_gt(Left.Node'Address,Right.Node'Address) /= 0;
   end ">";

   function ">="(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_ge(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_ge,"pugi_is_ge");
   begin
      return is_ge(Left.Node'Address,Right.Node'Address) /= 0;
   end ">=";

   procedure First_Attribute(Obj: XML_Node; Attr: out XML_Attribute'Class) is
      function get_first(Obj: System.Address) return System.Address;
      pragma Import(C,get_first,"pugi_first_attr");
   begin
      Attr.Attr := get_first(Obj.Node);
   end First_Attribute;

   procedure Last_Attribute(Obj: XML_Node; Attr: out XML_Attribute'Class) is
      function get_last(Obj: System.Address) return System.Address;
      pragma Import(C,get_last,"pugi_last_attr");
   begin
      Attr.Attr := get_last(Obj.Node);
   end Last_Attribute;

   function Text(Obj: XML_Node) return String is
      function text(Node: System.Address) return System.Address;
      pragma Import(C,text,"pugi_text");
      C_Str :  constant System.Address := text(Obj.Node);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Text;

   procedure Attribute(Obj: XML_Node; Name: String; Attr: out XML_Attribute'Class) is
      function get_attr(Node: System.Address; Name: System.Address) return System.Address;
      pragma Import(C,get_attr,"pugi_attr");
      C_Name:  aliased String := C_String(Name);
   begin
      Attr.Attr := get_attr(Obj.Node,C_Name'Address);
   end Attribute;

   function Name(Obj: XML_Attribute) return String is
      function get_name(Attr: System.Address) return System.Address;
      pragma Import(C,get_name,"pugi_attr_name");
      C_Str :  constant System.Address := get_name(Obj.Attr);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Name;

   function Value(Obj: XML_Attribute) return String is
      function get_value(Attr: System.Address) return System.Address;
      pragma Import(C,get_value,"pugi_attr_value");
      C_Str :  constant System.Address := get_value(Obj.Attr);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Value;

   function Empty(Obj: XML_Attribute) return Boolean is
      function attr_empty(Node: System.Address) return Standard.Integer;
      pragma Import(C,attr_empty,"pugi_attr_empty");
   begin
      return attr_empty(Obj'Address) /= 0;
   end Empty;

   function "="(Left, Right: XML_Attribute) return Boolean is
      function is_eq(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_eq,"pugi_is_attr_eq");
   begin
      return is_eq(Left.Attr'Address,Right.Attr'Address) /= 0;
   end "=";

   function "<"(Left, Right: XML_Attribute) return Boolean is
      function is_lt(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_lt,"pugi_is_attr_lt");
   begin
      return is_lt(Left.Attr'Address,Right.Attr'Address) /= 0;
   end "<";

   function "<="(Left, Right: XML_Attribute) return Boolean is
      function is_le(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_le,"pugi_is_attr_le");
   begin
      return is_le(Left.Attr'Address,Right.Attr'Address) /= 0;
   end "<=";

   function ">"(Left, Right: XML_Attribute) return Boolean is
      function is_gt(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_gt,"pugi_is_attr_gt");
   begin
      return is_gt(Left.Attr'Address,Right.Attr'Address) /= 0;
   end ">";

   function ">="(Left, Right: XML_Attribute) return Boolean is
      function is_ge(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_ge,"pugi_is_attr_ge");
   begin
      return is_ge(Left.Attr'Address,Right.Attr'Address) /= 0;
   end ">=";

   procedure Append_Attribute(Obj: XML_Node; Name: String; Attr: out XML_Attribute'Class) is
      function insert(Obj, Name: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_append_attr");
      C_Name: aliased String := C_String(Name);
   begin
      Attr.Attr := insert(Obj.Node,C_Name'Address);
   end Append_Attribute;
   
   procedure Prepend_Attribute(Obj: XML_Node; Name: String; Attr: out XML_Attribute'Class) is
      function insert(Obj, Name: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_prepend_attr");
      C_Name: aliased String := C_String(Name);
   begin
      Attr.Attr := insert(Obj.Node,C_Name'Address);
   end Prepend_Attribute;
   
   procedure Insert_Attribute_After(Obj: XML_Node; Name: String; Other: XML_Attribute'Class; Attr: out XML_Attribute'Class) is
      function insert(Obj, Name, Other: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_append_after");
      C_Name: aliased String := C_String(Name);
   begin
      Attr.Attr := insert(Obj.Node,C_Name'Address,Other.Attr);
   end Insert_Attribute_After;
   
   procedure Insert_Attribute_Before(Obj: XML_Node; Name: String; Other: XML_Attribute'Class; Attr: out XML_Attribute'Class) is
      function insert(Obj, Name, Other: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_append_before");
      C_Name: aliased String := C_String(Name);
   begin
      Attr.Attr := insert(Obj.Node,C_Name'Address,Other.Attr);
   end Insert_Attribute_Before;

   procedure Next_Attribute(Obj: XML_Attribute; Next: out XML_Attribute'Class) is
      function get_next(Obj: System.Address) return System.Address;
      pragma Import(C,get_next,"pugi_next_attr");
   begin
      Next.Attr := get_next(Obj.Attr);
   end Next_Attribute;

   procedure Previous_Attribute(Obj: XML_Attribute; Prev: out XML_Attribute'Class) is
      function get_prev(Obj: System.Address) return System.Address;
      pragma Import(C,get_prev,"pugi_prev_attr");
   begin
      Prev.Attr := get_prev(Obj.Attr);
   end Previous_Attribute;

   function Is_Null(Obj: XML_Attribute) return Boolean is
      use System;
   begin
      return Obj.Attr = System.Null_Address;
   end Is_Null;

   procedure Append_Copy(Obj: XML_Node; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class) is
      function append(Obj, Proto: System.Address) return System.Address;
      pragma Import(C,append,"pugi_append_copy");
   begin
      Attr.Attr := append(Obj.Node,Proto.Attr);
   end Append_Copy;
   
   procedure Prepend_Copy(Obj: XML_Node; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class) is
      function prepend(Obj, Proto: System.Address) return System.Address;
      pragma Import(C,prepend,"pugi_prepend_copy");
   begin
      Attr.Attr := prepend(Obj.Node,Proto.Attr);
   end Prepend_Copy;

   procedure Insert_Copy_After(Obj: XML_Node; After: XML_Attribute'Class; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class) is
      function insert(Obj, After, Proto: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_insert_copy_after");
   begin
      Attr.Attr := insert(Obj.Node,After.Attr,Proto.Attr);
   end Insert_Copy_After;
   
   procedure Insert_Copy_Before(Obj: XML_Node; Before: XML_Attribute'Class; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class) is
      function insert(Obj, Before, Proto: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_insert_copy_before");
   begin
      Attr.Attr := insert(Obj.Node,Before.Attr,Proto.Attr);
   end Insert_Copy_Before;

   procedure Append_Child(Obj: XML_Node; Node_Type: XML_Node_Type; Node: out XML_Node'Class) is
      function append(Obj: System.Address; Node_Type: Standard.Integer) return System.Address;
      pragma Import(C,append,"pugi_append_child_type");
   begin
      Node.Node := append(Obj.Node,XML_Node_Type'Pos(Node_Type));
   end Append_Child;
   
   procedure Prepend_Child(Obj: XML_Node; Node_Type: XML_Node_Type; Node: out XML_Node'Class) is
      function prepend(Obj: System.Address; Node_Type: Standard.Integer) return System.Address;
      pragma Import(C,prepend,"pugi_prepend_child_type");
   begin
      Node.Node := prepend(Obj.Node,XML_Node_Type'Pos(Node_Type));
   end Prepend_Child;
   
   procedure Insert_Child_After(Obj: XML_Node; After: XML_Node'Class; Node_Type: XML_Node_Type; Node: out XML_Node'Class) is
      function insert(Obj, After: System.Address; Node_Type: Standard.Integer) return System.Address;
      pragma Import(C,insert,"pugi_insert_child_type_after");
   begin
      Node.Node := insert(Obj.Node,After.Node,XML_Node_Type'Pos(Node_Type));
   end Insert_Child_After;
   
   procedure Insert_Child_Before(Obj: XML_Node; Before: XML_Node'Class; Node_Type: XML_Node_Type; Node: out XML_Node'Class) is
      function insert(Obj, Before: System.Address; Node_Type: Standard.Integer) return System.Address;
      pragma Import(C,insert,"pugi_insert_child_type_before");
   begin
      Node.Node := insert(Obj.Node,Before.Node,XML_Node_Type'Pos(Node_Type));
   end Insert_Child_Before;

   procedure Append_Child(Obj: XML_Node; Name: String; Node: out XML_Node'Class) is
      function append(Obj, Name: System.Address) return System.Address;
      pragma Import(C,append,"pugi_append_child_node");
      C_Name: aliased String := C_String(Name);
   begin
      Node.Node := append(Obj.Node,C_Name'Address);
   end Append_Child;
   
   procedure Prepend_Child(Obj: XML_Node; Name: String; Node: out XML_Node'Class) is
      function prepend(Obj, Name: System.Address) return System.Address;
      pragma Import(C,prepend,"pugi_prepend_child_node");
      C_Name: aliased String := C_String(Name);
   begin
      Node.Node := prepend(Obj.Node,C_Name'Address);
   end Prepend_Child;
   
   procedure Insert_Child_After(Obj: XML_Node; After: XML_Node'Class; Name: String; Node: out XML_Node'Class) is
      function insert(Obj, After, Name: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_insert_child_node_after");
      C_Name: aliased String := C_String(Name);
   begin
      Node.Node := insert(Obj.Node,After.Node,C_Name'Address);
   end Insert_Child_After;
   
   procedure Insert_Child_Before(Obj: XML_Node; Before: XML_Node'Class; Name: String; Node: out XML_Node'Class) is
      function insert(Obj, Before, Name: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_insert_child_node_before");
      C_Name: aliased String := C_String(Name);
   begin
      Node.Node := insert(Obj.Node,Before.Node,C_Name'Address);
   end Insert_Child_Before;
   
   procedure Append_Copy(Obj: XML_Node; Proto: XML_Node'Class; Node: out XML_Node'Class) is
      function append(Obj, Proto: System.Address) return System.Address;
      pragma Import(C,append,"pugi_append_copy_node");
   begin
      Node.Node := append(Obj.Node,Proto.Node);
   end Append_Copy;

   procedure Prepend_Copy(Obj: XML_Node; Proto: XML_Node'Class; Node: out XML_Node'Class) is
      function prepend(Obj, Proto: System.Address) return System.Address;
      pragma Import(C,prepend,"pugi_prepend_copy_node");
   begin
      Node.Node := prepend(Obj.Node,Proto.Node);
   end Prepend_Copy;

   procedure Insert_Copy_After(Obj: XML_Node; After, Proto: XML_Node'Class; Node: out XML_Node'Class) is
    function insert(Obj, After, Proto: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_insert_copy_node_after");
   begin
      Node.Node := insert(Obj.Node,After.Node,Proto.Node);
   end Insert_Copy_After;

   procedure Insert_Copy_Before(Obj: XML_Node; Before, Proto: XML_Node'Class; Node: out XML_Node'Class) is
      function insert(Obj, Before, Proto: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_insert_copy_node_before");
   begin
      Node.Node := insert(Obj.Node,Before.Node,Proto.Node);
   end Insert_Copy_Before;

   procedure Remove_Attribute(Obj: XML_Node; Attr: XML_Attribute'Class; OK: out Boolean) is
      function remove(Obj, Attr: System.Address) return Standard.Integer;
      pragma Import(C,remove,"pugi_remove_attr");
   begin
      OK := remove(Obj.Node,Attr.Attr) /= 0;
   end Remove_Attribute;
   
   procedure Remove_Attribute(Obj: XML_Node; Name: String; OK: out Boolean) is
      function remove(Obj, Name: System.Address) return Standard.Integer;
      pragma Import(C,remove,"pugi_remove_attr_name");
      C_Name: aliased String := C_String(Name);
   begin
      OK := remove(Obj.Node,C_Name'Address) /= 0;
   end Remove_Attribute;

   procedure Remove_Child(Obj: XML_Node; Node: XML_Node'Class; OK: out Boolean) is
      function remove(Obj, Attr: System.Address) return Standard.Integer;
      pragma Import(C,remove,"pugi_remove_attr");
   begin
      OK := remove(Obj.Node,Node.Node) /= 0;
   end Remove_Child;
   
   procedure Remove_Child(Obj: XML_Node; Name: String; OK: out Boolean) is
      function remove(Obj, Name: System.Address) return Standard.Integer;
      pragma Import(C,remove,"pugi_remove_child_name");
      C_Name: aliased String := C_String(Name);
   begin
      OK := remove(Obj.Node,C_Name'Address) /= 0;
   end Remove_Child;

   function Find_First_By_Path(Obj: XML_Node; Path: String; Delimiter: Character := '/') return XML_Node is
      function find(Obj, Path: System.Address; Delim: Character) return System.Address;
      pragma Import(C,find,"pugi_find_by_path");
      C_Path: aliased String := C_String(Path);
      Node: XML_Node;
   begin
      Node.Node := find(Obj.Node,C_Path'Address,Delimiter);
      return Node;
   end Find_First_By_Path;

   function As_Int(Obj: XML_Attribute) return Standard.Integer is
      function as_value(Obj: System.Address) return Standard.Integer;
      pragma Import(C,as_value,"pugi_attr_as_int");
   begin
      return as_value(Obj.Attr);
   end As_Int;

   function As_Uint(Obj: XML_Attribute) return Interfaces.C.unsigned is
      function as_value(Obj: System.Address) return Interfaces.C.unsigned;
      pragma Import(C,as_value,"pugi_attr_as_uint");
   begin
      return as_value(Obj.Attr);
   end As_Uint;
   
   function As_Double(Obj: XML_Attribute) return Interfaces.C.double is
      function as_value(Obj: System.Address) return Interfaces.C.double;
      pragma Import(C,as_value,"pugi_attr_as_double");
   begin
      return as_value(Obj.Attr);
   end As_Double;

   function As_Float(Obj: XML_Attribute) return Standard.Float is
      function as_value(Obj: System.Address) return Interfaces.C.C_float;
      pragma Import(C,as_value,"pugi_attr_as_float");
   begin
      return Standard.Float(as_value(Obj.Attr));
 end As_Float;

   function As_Boolean(Obj: XML_Attribute) return Boolean is
      function as_value(Obj: System.Address) return Standard.Integer;
      pragma Import(C,as_value,"pugi_attr_as_bool");
   begin
      return as_value(Obj.Attr) /= 0;
   end As_Boolean;

   procedure Set_Name(Obj: XML_Attribute; Name: String) is
      procedure set_name(Obj, Name: System.Address);
      pragma Import(C,set_name,"pugi_set_attr_name");
      C_Name: aliased String := C_String(Name);
   begin
      set_name(Obj.Attr,C_Name'Address);
   end Set_Name;
   
   procedure Set_Value(Obj: XML_Attribute; Value: String) is
      procedure set_value(Obj, Name: System.Address);
      pragma Import(C,set_value,"pugi_set_attr_value");
      C_Value: aliased String := C_String(Value);
   begin
      set_value(Obj.Attr,C_Value'Address);
   end Set_Value;
   
   procedure Set_Value(Obj: XML_Attribute; Value: Standard.Integer) is
      procedure set_value(Obj: System.Address; Value: Standard.Integer);
      pragma Import(C,set_value,"pugi_set_attr_int");
   begin
      set_value(Obj.Attr,Value);
   end Set_Value;
   
   procedure Set_Value(Obj: XML_Attribute; Value: Interfaces.C.Unsigned) is
      procedure set_value(Obj: System.Address; Value: Interfaces.C.Unsigned);
      pragma Import(C,set_value,"pugi_set_attr_uint");
   begin
      set_value(Obj.Attr,Value);
 end Set_Value;
   
   procedure Set_Value(Obj: XML_Attribute; Value: Standard.Float) is
      procedure set_value(Obj: System.Address; Value: Standard.Float);
      pragma Import(C,set_value,"pugi_set_attr_float");
   begin
      set_value(Obj.Attr,Value);
   end Set_Value;
   
   procedure Set_Value(Obj: XML_Attribute; Value: Interfaces.C.Double) is
      procedure set_value(Obj: System.Address; Value: Interfaces.C.Double);
      pragma Import(C,set_value,"pugi_set_attr_double");
   begin
      set_value(Obj.Attr,Value);
   end Set_Value;
   
   procedure Set_Value(Obj: XML_Attribute; Value: Boolean) is
      procedure set_value(Obj: System.Address; Value: Standard.Integer);
      pragma Import(C,set_value,"pugi_set_attr_bool");
   begin
      if Value then
         set_value(Obj.Attr,1);
      else
         set_value(Obj.Attr,0);
      end if;
   end Set_Value;
   
   function Status(Obj: XML_Parse_Result) return XML_Parse_Status is
   begin
      return Obj.Status;
   end Status;

   function Offset(Obj: XML_Parse_Result) return Interfaces.C.Unsigned is
   begin
      return Obj.Offset;
   end Offset;

   function Encoding(Obj: XML_Parse_Result) return XML_Encoding is
   begin
      return Obj.Encoding;
   end Encoding;
   
   function Description(Obj: XML_Parse_Result) return String is
      Len :    constant Natural := Strlen(Obj.C_Desc);
      Desc :   String(1..Len);
      for Desc'Address use Obj.C_Desc;
   begin
      return Desc;
   end Description;

   function OK(Obj: XML_Parse_Result) return Boolean is
      function is_ok(Obj: System.Address) return Standard.Integer;
      pragma Import(C,is_ok,"pugi_is_parse_ok");
   begin
      return Obj.OK;
   end OK;

end Pugi_Xml;
