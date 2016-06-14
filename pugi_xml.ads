-- pugi_xml.ads - Fri Jun 10 21:47:48 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with System, Ada.Finalization, Interfaces.C, Ada.Characters.Latin_1;

package Pugi_Xml is

   type XML_Node_Type is (
      Node_Null,        -- Empty (null) node handle
      Node_Document,	-- A document tree's absolute root
      Node_Element,	-- Element tag, i.e. '<node/>'
      Node_Pcdata,	-- Plain character data, i.e. 'text'
      Node_Cdata,	-- Character data, i.e. '<![CDATA[text]]>'
      Node_Comment,	-- Comment tag, i.e. '<!-- text -->'
      Node_Pi,		-- Processing instruction, i.e. '<?name?>'
      Node_Declaration,	-- Document declaration, i.e. '<?xml version="1.0"?>'
      Node_Doctype	-- Document type declaration, i.e. '<!DOCTYPE doc>'
   );   

   for XML_Node_Type use (    -- These must match pugixml.hpp values
      Node_Null => 0,
      Node_Document => 1,
      Node_Element => 2,
      Node_Pcdata => 3,
      Node_Cdata => 4,
      Node_Comment => 5,
      Node_Pi => 6,
      Node_Declaration => 7,
      Node_Doctype => 8
   );

   type XML_Encoding is (
      Encoding_Auto,          -- Auto-detect input encoding using BOM or < / <? detection; use UTF8 if BOM is not found
      Encoding_UTF8,          -- UTF8 encoding
      Encoding_UTF16_LE,      -- Little-endian UTF16
      Encoding_UTF16_BE,      -- Big-endian UTF16
      Encoding_UTF16,         -- UTF16 with native endianness
      Encoding_UTF32_LE,      -- Little-endian UTF32
      Encoding_UTF32_BE,      -- Big-endian UTF32
      Encoding_UTF32,         -- UTF32 with native endianness
      Encoding_Wchar,         -- The same encoding wchar_t has (either UTF16 or UTF32)
      Encoding_Latin1
   );

   for XML_Encoding use (
      Encoding_Auto => 0,
      Encoding_UTF8 => 1,
      Encoding_UTF16_LE => 2,
      Encoding_UTF16_BE => 3,
      Encoding_UTF16 => 4,
      Encoding_UTF32_LE => 5,
      Encoding_UTF32_BE => 6,
      Encoding_UTF32 => 7,
      Encoding_Wchar => 8,
      Encoding_Latin1 => 9
   );

   type XML_Parse_Status is (
      Status_OK,                    -- No error
      Status_File_Not_Found,        -- File was not found during load_file()
      Status_IO_Error,              -- Error reading from file/stream
      Status_Out_Of_Memory,         -- Could not allocate memory
      Status_Internal_Error,        -- Internal error occurred
      Status_Unrecognized_Tag,      -- Parser could not determine tag type
      Status_Bad_Pi,                -- Parsing error occurred while parsing document declaration/processing instruction
      Status_Bad_Comment,           -- Parsing error occurred while parsing comment
      Status_Bad_Cdata,             -- Parsing error occurred while parsing CDATA section
      Status_Bad_Doctype,           -- Parsing error occurred while parsing document type declaration
      Status_Bad_Pcdata,            -- Parsing error occurred while parsing PCDATA section
      Status_Bad_Start_Element,     -- Parsing error occurred while parsing start element tag
      Status_Bad_Attribute,         -- Parsing error occurred while parsing element attribute
      Status_Bad_End_Element,       -- Parsing error occurred while parsing end element tag
      Status_End_Element_Mismatch   -- There was a mismatch of start-end tags (closing tag had incorrect name, some tag was not closed or there was an excessive closing tag)
   );

   for XML_Parse_Status use (
      Status_OK => 0,
      Status_File_Not_Found => 1,
      Status_IO_Error => 2,
      Status_Out_Of_Memory => 3,
      Status_Internal_Error => 4,
      Status_Unrecognized_Tag => 5,
      Status_Bad_Pi => 6,
      Status_Bad_Comment => 7,
      Status_Bad_Cdata => 8,
      Status_Bad_Doctype => 9,
      Status_Bad_Pcdata => 10,
      Status_Bad_Start_Element => 11,
      Status_Bad_Attribute => 12,
      Status_Bad_End_Element => 13,
      Status_End_Element_Mismatch => 14
   );

   type XML_Parse_Result is tagged private;
   type XML_Document is new Ada.Finalization.Controlled with private;
   type XML_Node is new Ada.Finalization.Controlled with private;
   type XML_Attribute is new Ada.Finalization.Controlled with private;

   -- XML_Parse_Result
   function Status(Obj: XML_Parse_Result) return XML_Parse_Status;
   function Offset(Obj: XML_Parse_Result) return Interfaces.C.Unsigned;
   function Encoding(Obj: XML_Parse_Result) return XML_Encoding;
   function Description(Obj: XML_Parse_Result) return String;   
   function OK(Obj: XML_Parse_Result) return Boolean;

   -- XML_Document
   procedure As_Root(Obj: XML_Document; Node: out XML_Node'Class);
   procedure Load(Obj: XML_Document; Pathname: string; Result: out XML_Parse_Result'Class);
   procedure Load_In_Place(Obj: XML_Document; Contents: System.Address; Bytes: Standard.Integer; Encoding: XML_Encoding := Encoding_Auto; Result: out XML_Parse_Result'Class);
   procedure Child(Obj: XML_Document; Name: String; Node: out XML_Node'Class);
   procedure Reset(Obj: XML_Document);
   procedure Reset(Obj: XML_Document; Proto: XML_Document'Class);

   Indent_Default : constant String(1..1) := (others => Ada.Characters.Latin_1.HT);

   procedure Save(Obj: XML_Document; Pathname: String; OK: out Boolean; Indent: String := Indent_Default; Encoding: XML_Encoding := Encoding_Auto);

   -- // Load document from buffer. Copies/converts the buffer, so it may be deleted or changed after the function returns.
   -- xml_parse_result load_buffer(const void* contents, size_t size, unsigned int options = parse_default, xml_encoding encoding = encoding_auto);
   -- 
   -- // Load document from buffer, using the buffer for in-place parsing (the buffer is modified and used for storage of document data).
   -- // You should ensure that buffer data will persist throughout the document's lifetime, and free the buffer memory manually once document is destroyed.
   -- xml_parse_result load_buffer_inplace(void* contents, size_t size, unsigned int options = parse_default, xml_encoding encoding = encoding_auto);
   -- 
   -- // Load document from buffer, using the buffer for in-place parsing (the buffer is modified and used for storage of document data).
   -- // You should allocate the buffer with pugixml allocation function; document will free the buffer when it is no longer needed (you can't use it anymore).
   -- xml_parse_result load_buffer_inplace_own(void* contents, size_t size, unsigned int options = parse_default, xml_encoding encoding = encoding_auto);
   -- 
   -- // Save XML document to writer (semantics is slightly different from xml_node::print, see documentation for details).
   -- void save(xml_writer& writer, const char_t* indent = PUGIXML_TEXT("\t"), unsigned int flags = format_default, xml_encoding encoding = encoding_auto) const;
   -- 
   -- #ifndef PUGIXML_NO_STL
   -- // Save XML document to stream (semantics is slightly different from xml_node::print, see documentation for details).
   -- void save(std::basic_ostream<char, std::char_traits<char> >& stream, const char_t* indent = PUGIXML_TEXT("\t"), unsigned int flags = format_default, xml_encoding encoding = $
   -- void save(std::basic_ostream<wchar_t, std::char_traits<wchar_t> >& stream, const char_t* indent = PUGIXML_TEXT("\t"), unsigned int flags = format_default) const;
   -- #endif
   -- 
   -- // Save XML to file
   -- bool save_file(const char* path, const char_t* indent = PUGIXML_TEXT("\t"), unsigned int flags = format_default, xml_encoding encoding = encoding_auto) const;
   -- bool save_file(const wchar_t* path, const char_t* indent = PUGIXML_TEXT("\t"), unsigned int flags = format_default, xml_encoding encoding = encoding_auto) const;


   -- XML_Node
   function Name(Obj: XML_Node) return String;
   procedure Parent(Obj: XML_Node; Node: out XML_Node'Class);
   procedure Child(Obj: XML_Node; Name: String; Node: out XML_Node'Class);
   function Empty(Obj: XML_Node) return Boolean;
   function Node_Type(Obj: XML_Node) return XML_Node_Type;
   function Value(Obj: XML_Node) return String;
   procedure First_Child(Obj: XML_Node; Node: out XML_Node);
   procedure Last_Child(Obj: XML_Node; Node: out XML_Node);
   procedure Root_Node(Obj: XML_Node; Node: out XML_Node);
   procedure Next_Sibling(Obj: XML_Node; Node: out XML_Node);
   procedure Next_Sibling(Obj: XML_Node; Name: String; Node: out XML_Node);
   procedure Previous_Sibling(Obj: XML_Node; Node: out XML_Node);
   procedure Previous_Sibling(Obj: XML_Node; Name: String; Node: out XML_Node);
   function Is_Null(Obj: XML_Node) return Boolean;
   function Child_Value(Obj: XML_Node) return String;
   function Child_Value(Obj: XML_Node; Name: String) return String;

   procedure Append_Copy(Obj: XML_Node; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class);
   procedure Prepend_Copy(Obj: XML_Node; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class);
   procedure Insert_Copy_After(Obj: XML_Node; After: XML_Attribute'Class; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class);
   procedure Insert_Copy_Before(Obj: XML_Node; Before: XML_Attribute'Class; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class);

   function "="(Left: XML_Node; Right: XML_Node) return Boolean;
   function "<"(Left: XML_Node; Right: XML_Node) return Boolean;
   function "<="(Left: XML_Node; Right: XML_Node) return Boolean;
   function ">"(Left: XML_Node; Right: XML_Node) return Boolean;
   function ">="(Left: XML_Node; Right: XML_Node) return Boolean;

   procedure Set_Name(Obj: XML_Node; Data: String; OK: out Boolean);
   procedure Set_Value(Obj: XML_Node; Data: String; OK: out Boolean);

   procedure First_Attribute(Obj: XML_Node; Attr: out XML_Attribute'Class);
   procedure Last_Attribute(Obj: XML_Node; Attr: out XML_Attribute'Class);
   procedure Attribute(Obj: XML_Node; Name: String; Attr: out XML_Attribute'Class);

   function Text(Obj: XML_Node) return String;

   procedure Append_Attribute(Obj: XML_Node; Name: String; Attr: out XML_Attribute'Class);
   procedure Prepend_Attribute(Obj: XML_Node; Name: String; Attr: out XML_Attribute'Class);
   procedure Insert_Attribute_After(Obj: XML_Node; Name: String; Other: XML_Attribute'Class; Attr: out XML_Attribute'Class);
   procedure Insert_Attribute_Before(Obj: XML_Node; Name: String; Other: XML_Attribute'Class; Attr: out XML_Attribute'Class);

   procedure Append_Child(Obj: XML_Node; Node_Type: XML_Node_Type; Node: out XML_Node'Class);
   procedure Prepend_Child(Obj: XML_Node; Node_Type: XML_Node_Type; Node: out XML_Node'Class);
   procedure Insert_Child_After(Obj: XML_Node; After: XML_Node'Class; Node_Type: XML_Node_Type; Node: out XML_Node'Class);
   procedure Insert_Child_Before(Obj: XML_Node; Before: XML_Node'Class; Node_Type: XML_Node_Type; Node: out XML_Node'Class);

   procedure Append_Child(Obj: XML_Node; Name: String; Node: out XML_Node'Class);
   procedure Prepend_Child(Obj: XML_Node; Name: String; Node: out XML_Node'Class);
   procedure Insert_Child_After(Obj: XML_Node; After: XML_Node'Class; Name: String; Node: out XML_Node'Class);
   procedure Insert_Child_Before(Obj: XML_Node; Before: XML_Node'Class; Name: String; Node: out XML_Node'Class);

   procedure Append_Copy(Obj: XML_Node; Proto: XML_Node'Class; Node: out XML_Node'Class);
   procedure Prepend_Copy(Obj: XML_Node; Proto: XML_Node'Class; Node: out XML_Node'Class);
   procedure Insert_Copy_After(Obj: XML_Node; After, Proto: XML_Node'Class; Node: out XML_Node'Class);
   procedure Insert_Copy_Before(Obj: XML_Node; Before, Proto: XML_Node'Class; Node: out XML_Node'Class);

   procedure Remove_Attribute(Obj: XML_Node; Attr: XML_Attribute'Class; OK: out Boolean);
   procedure Remove_Attribute(Obj: XML_Node; Name: String; OK: out Boolean);

   procedure Remove_Child(Obj: XML_Node; Node: XML_Node'Class; OK: out Boolean);
   procedure Remove_Child(Obj: XML_Node; Name: String; OK: out Boolean);

   function Find_First_By_Path(Obj: XML_Node; Path: String; Delimiter: Character := '/') return XML_Node;

   function Name(Obj: XML_Attribute) return String;
   function Value(Obj: XML_Attribute) return String;
   function Empty(Obj: XML_Attribute) return Boolean;

   function "="(Left, Right: XML_Attribute) return Boolean;
   function "<"(Left, Right: XML_Attribute) return Boolean;
   function "<="(Left, Right: XML_Attribute) return Boolean;
   function ">"(Left, Right: XML_Attribute) return Boolean;
   function ">="(Left, Right: XML_Attribute) return Boolean;

   procedure Next_Attribute(Obj: XML_Attribute; Next: out XML_Attribute'Class);
   procedure Previous_Attribute(Obj: XML_Attribute; Prev: out XML_Attribute'Class);

   function Is_Null(Obj: XML_Attribute) return Boolean;

   function As_Int(Obj: XML_Attribute) return Standard.Integer;
   function As_Uint(Obj: XML_Attribute) return Interfaces.C.unsigned;
   function As_Double(Obj: XML_Attribute) return Interfaces.C.double;
   function As_Float(Obj: XML_Attribute) return Standard.Float;
   function As_Boolean(Obj: XML_Attribute) return Boolean;
   
   procedure Set_Name(Obj: XML_Attribute; Name: String);
   procedure Set_Value(Obj: XML_Attribute; Value: String);
   procedure Set_Value(Obj: XML_Attribute; Value: Standard.Integer);
   procedure Set_Value(Obj: XML_Attribute; Value: Interfaces.C.Unsigned);
   procedure Set_Value(Obj: XML_Attribute; Value: Standard.Float);
   procedure Set_Value(Obj: XML_Attribute; Value: Interfaces.C.Double);
   procedure Set_Value(Obj: XML_Attribute; Value: Boolean);

private

   type XML_Document is new Ada.Finalization.Controlled with
      record
         Doc:        System.Address;   -- ptr to pugi::xml_document
      end record;

   procedure Initialize(Obj: in out XML_Document);
   procedure Finalize(Obj: in out XML_Document);

   type XML_Node is new Ada.Finalization.Controlled with
      record
         Node:       System.Address;   -- pugi::xml_node
      end record;

   procedure Initialize(Obj: in out XML_Node);
   procedure Finalize(Obj: in out XML_Node);

   type XML_Attribute is new Ada.Finalization.Controlled with
      record
         Attr:       System.Address;   -- pugi::xml_attribute
      end record;

   procedure Initialize(Obj: in out XML_Attribute);
   procedure Finalize(Obj: in out XML_Attribute);

   type XML_Parse_Result is tagged
      record
         Status:     XML_Parse_Status        := Status_OK;
         Offset:     Interfaces.C.Unsigned   := 0;
         Encoding:   XML_Encoding            := Encoding_Auto;
         OK:         Boolean                 := True;
         C_Desc:     System.Address          := System.Null_Address;
      end record;

end Pugi_Xml;
