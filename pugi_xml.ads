-- pugi_xml.ads - Fri Jun 10 21:47:48 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with System, Ada.Finalization, Interfaces.C, Ada.Characters.Latin_1;

package Pugi_Xml is

   type XML_Parse_Flags is
      record
         Parse_Pi:               Boolean; -- determines if processing instructions (node_pi) are added to the DOM tree. This flag is off by default.
         Parse_Comments:         Boolean; -- determines if comments (node_comment) are added to the DOM tree. This flag is off by default.
         Parse_Cdata:            Boolean; -- determines if CDATA sections (node_cdata) are added to the DOM tree. This flag is on by default.
         Parse_Ws_Pcdata:        Boolean; -- determines if plain character data (node_pcdata) that consist only of whitespace are added to the DOM tree.
                                          -- is off by default; turning it on usually results in slower parsing and more memory consumption.
         Parse_Escapes:          Boolean; -- determines if character and entity references are expanded during parsing. This flag is on by default.
         Parse_Eol:              Boolean; -- determines if EOL characters are normalized (converted to #xA) during parsing. This flag is on by default.
         Parse_Wconv_Attribute:  Boolean; -- determines if attribute values are normalized using CDATA normalization rules during parsing. This flag is on by default.
         Parse_Wnorm_Attribute:  Boolean; -- determines if attribute values are normalized using NMTOKENS normalization rules during parsing. This flag is off by default.
         Parse_Declaration:      Boolean; -- determines if document declaration (node_declaration) is added to the DOM tree. This flag is off by default.
         Parse_Doctype:          Boolean; -- determines if document type declaration (node_doctype) is added to the DOM tree. This flag is off by default.
         Parse_Ws_Pcdata_Single: Boolean; -- determines if plain character data (node_pcdata) that is the only child of the parent node and that consists only
                                          -- of whitespace is added to the DOM tree.
                                          -- This flag is off by default; turning it on may result in slower parsing and more memory consumption.
         Parse_Trim_Pcdata:      Boolean; -- determines if leading and trailing whitespace is to be removed from plain character data. This flag is off by default.
         Parse_Fragment:         Boolean; -- determines if plain character data that does not have a parent node is added to the DOM tree, and if an empty document
                                          -- is a valid document. This flag is off by default.
      end record;

   for XML_Parse_Flags use
      record
         Parse_Pi                at 0 range 0..0;     -- 0x0001
         Parse_Comments          at 0 range 1..1;     -- 0x0002
         Parse_Cdata             at 0 range 2..2;     -- 0x0004
         Parse_Ws_Pcdata         at 0 range 3..3;     -- 0x0008
         Parse_Escapes           at 0 range 4..4;     -- 0x0010
         Parse_Eol               at 0 range 5..5;     -- 0x0020
         Parse_Wconv_Attribute   at 0 range 6..6;     -- 0x0040
         Parse_Wnorm_Attribute   at 0 range 7..7;     -- 0x0080
         Parse_Declaration       at 0 range 8..8;     -- 0x0100
         Parse_Doctype           at 0 range 9..9;     -- 0x0200
         Parse_Ws_Pcdata_Single  at 0 range 10..10;   -- 0x0400
         Parse_Trim_Pcdata       at 0 range 11..11;   -- 0x0800
         Parse_Fragment          at 0 range 12..12;   -- 0x1000
      end record;

   for XML_Parse_Flags'Size use 32;
   for XML_Parse_Flags'Bit_Order use System.Low_Order_First;

   Parse_Minimal_Flags: constant XML_Parse_Flags := (
      others => False
   );

   Parse_Default_Flags: constant XML_Parse_Flags := (
      Parse_Cdata => True,
      Parse_Escapes => True,
      Parse_Wconv_Attribute => True,
      Parse_Eol => True,
      others => False
   );

   Parse_Full_Flags:    constant XML_Parse_Flags := (
      Parse_Pi => True,
      Parse_Comments => True,
      Parse_Cdata => True,
      Parse_Escapes => True,
      Parse_Wconv_Attribute => True,
      Parse_Declaration => True,
      Parse_Doctype => True,
      Parse_Eol => True,
      others => False
   );

   type XML_Format_Flags is
      record
         Format_Indent:             Boolean;                  
         Format_Write_Bom:          Boolean;                     
         Format_Raw:                Boolean;               
         Format_No_Declaration:     Boolean;                           
         Format_No_Escapes:         Boolean;                        
         Format_Save_File_Text:     Boolean;                           
         Format_Indent_Attributes:  Boolean;
      end record;

   for XML_Format_Flags use
      record
         format_indent              at 0 range 0..0;  -- 0x01; Indent the nodes that are written to output stream with as many indentation strings as deep the node is in DOM tree. This flag is on by default.
         format_write_bom           at 0 range 1..1;  -- 0x02; Write encoding-specific BOM to the output stream. This flag is off by default.
         format_raw                 at 0 range 2..2;  -- 0x04; Use raw output mode (no indentation and no line breaks are written). This flag is off by default.
         format_no_declaration      at 0 range 3..3;  -- 0x08; Omit default XML declaration even if there is no declaration in the document. This flag is off by default.
         format_no_escapes          at 0 range 4..4;  -- 0x10; Don't escape attribute values and PCDATA contents. This flag is off by default.
         format_save_file_text      at 0 range 5..5;  -- 0x20; Open file using text mode in xml_document::save_file. This enables special character (i.e. new-line) conversions on some systems. This flag is off by default.
         format_indent_attributes   at 0 range 6..6;  -- 0x40; Write every attribute on a new line with appropriate indentation. This flag is off by default.
      end record;

   for XML_Format_Flags'Size use 32;
   for XML_Format_Flags'Bit_Order use System.Low_Order_First;

   Format_Default_Flags:   constant XML_Format_Flags := (
      Format_Indent => True,
      others => False
   );

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

   Indent_Default : constant String(1..1) := (others => Ada.Characters.Latin_1.HT);

   -- XML_Parse_Result
   function Status(Obj: XML_Parse_Result) return XML_Parse_Status;
   function Offset(Obj: XML_Parse_Result) return Natural;
   function Encoding(Obj: XML_Parse_Result) return XML_Encoding;
   function Description(Obj: XML_Parse_Result) return String;   
   function OK(Obj: XML_Parse_Result) return Boolean;

   -- XML_Document
   function Root(Obj: XML_Document'Class) return XML_Node;
   procedure Load(
      Obj: XML_Document;
      Pathname: string;
      Options: XML_Parse_Flags := Parse_Default_Flags;
      Encoding_Option: XML_Encoding := Encoding_Auto;
      Result: out XML_Parse_Result'Class
   );
   procedure Load_In_Place(
      Obj:        XML_Document;
      Contents:   System.Address;
      Bytes:      Standard.Integer;
      Options:    XML_Parse_Flags := Parse_Default_Flags;
      Encoding:   XML_Encoding := Encoding_Auto;
      Result: out XML_Parse_Result'Class
   );
   procedure Save(
      Obj: XML_Document;
      Pathname: String;
      OK: out Boolean;
      Indent: String := Indent_Default;
      Encoding: XML_Encoding := Encoding_Auto;
      Format: XML_Format_Flags := Format_Default_Flags
   );
   function Child(Obj: XML_Document'Class;  Name: String) return XML_Node;
   procedure Reset(Obj: XML_Document);
   procedure Reset(Obj: XML_Document; Proto: XML_Document'Class);

   -- XML_Node
   function Name(Obj: XML_Node) return String;
   function Parent(Obj: XML_Node'Class) return XML_Node;
   function Child(Obj: XML_Node'Class; Name: String) return XML_Node;
   function Empty(Obj: XML_Node) return Boolean;
   function Node_Type(Obj: XML_Node) return XML_Node_Type;
   function Value(Obj: XML_Node) return String;
   function First_Child(Obj: XML_Node'Class) return XML_Node;
   function Last_Child(Obj: XML_Node'Class) return XML_Node;
   function Root(Obj: XML_Node'Class) return XML_Node;
   function Next(Obj: XML_Node'Class) return XML_Node;
   function Next(Obj: XML_Node'Class; Name: String) return XML_Node;
   function Previous(Obj: XML_Node'Class) return XML_Node;
   function Previous(Obj: XML_Node'Class; Name: String) return XML_Node;
   function Is_Null(Obj: XML_Node) return Boolean;
   function Child_Value(Obj: XML_Node) return String;
   function Child_Value(Obj: XML_Node; Name: String) return String;

   function Append_Copy(Obj: XML_Node'Class; Proto: XML_Attribute'Class) return XML_Attribute;
   function Prepend_Copy(Obj: XML_Node'Class; Proto: XML_Attribute'Class) return XML_Attribute;
   function Insert_Copy_After(Obj: XML_Node'Class; After: XML_Attribute'Class; Proto: XML_Attribute'Class) return XML_Attribute;
   function Insert_Copy_Before(Obj: XML_Node'Class; Before: XML_Attribute'Class; Proto: XML_Attribute'Class) return XML_Attribute;

   function "="(Left: XML_Node; Right: XML_Node) return Boolean;

   function Set_Name(Obj: XML_Node; Data: String) return Boolean;
   function Set_Value(Obj: XML_Node; Data: String) return Boolean;

   function First_Attribute(Obj: XML_Node'Class) return XML_Attribute;
   function Last_Attribute(Obj: XML_Node'Class) return XML_Attribute;
   function Attribute(Obj: XML_Node'Class; Name: String) return XML_Attribute;

   function Text(Obj: XML_Node) return String;

   function Append_Attribute(Obj: XML_Node'Class; Name: String) return XML_Attribute;
   function Prepend_Attribute(Obj: XML_Node'Class; Name: String) return XML_Attribute;
   function Insert_Attribute_After(Obj: XML_Node'Class; Name: String; Other: XML_Attribute'Class) return XML_Attribute;
   function Insert_Attribute_Before(Obj: XML_Node'Class; Name: String; Other: XML_Attribute'Class) return XML_Attribute;

   function Append_Child(Obj: XML_Node'Class; Node_Type: XML_Node_Type) return XML_Node;
   function Prepend_Child(Obj: XML_Node'Class; Node_Type: XML_Node_Type) return XML_Node;
   function Insert_Child_After(Obj: XML_Node'Class; After: XML_Node'Class; Node_Type: XML_Node_Type) return XML_Node;
   function Insert_Child_Before(Obj: XML_Node'Class; Before: XML_Node'Class; Node_Type: XML_Node_Type) return XML_Node;

   function Append_Child(Obj: XML_Node'Class; Name: String) return XML_Node;
   function Prepend_Child(Obj: XML_Node'Class; Name: String) return XML_Node;
   function Insert_Child_After(Obj: XML_Node'Class; After: XML_Node'Class; Name: String) return XML_Node;
   function Insert_Child_Before(Obj: XML_Node'Class; Before: XML_Node'Class; Name: String) return XML_Node;

   function Append_Copy(Obj: XML_Node'Class; Proto: XML_Node'Class) return XML_Node;
   function Prepend_Copy(Obj: XML_Node'Class; Proto: XML_Node'Class) return XML_Node;
   function Insert_Copy_After(Obj: XML_Node'Class; After, Proto: XML_Node'Class) return XML_Node;
   function Insert_Copy_Before(Obj: XML_Node'Class; Before, Proto: XML_Node'Class) return XML_Node;

   function Remove_Attribute(Obj: XML_Node; Attr: XML_Attribute'Class) return Boolean;
   function Remove_Attribute(Obj: XML_Node; Name: String) return Boolean;

   function Remove_Child(Obj: XML_Node; Node: XML_Node'Class) return Boolean;
   function Remove_Child(Obj: XML_Node; Name: String) return Boolean;

   function Find_First_By_Path(Obj: XML_Node; Path: String; Delimiter: Character := '/') return XML_Node;

   function Name(Obj: XML_Attribute) return String;
   function Value(Obj: XML_Attribute) return String;
   function Empty(Obj: XML_Attribute) return Boolean;

   function "="(Left, Right: XML_Attribute) return Boolean;

   function Next(Obj: XML_Attribute'Class) return XML_Attribute;
   function Previous(Obj: XML_Attribute'Class) return XML_Attribute;

   function Is_Null(Obj: XML_Attribute) return Boolean;

   function As_Int(Obj: XML_Attribute) return Standard.Integer;
   function As_Uint(Obj: XML_Attribute) return Interfaces.C.unsigned;
   function As_Double(Obj: XML_Attribute) return Interfaces.C.double;
   function As_Float(Obj: XML_Attribute) return Standard.Float;
   function As_Boolean(Obj: XML_Attribute) return Boolean;
   
   function Set_Name(Obj: XML_Attribute; Name: String) return Boolean;
   function Set_Value(Obj: XML_Attribute; Value: String) return Boolean;
   function Set_Value(Obj: XML_Attribute; Value: Standard.Integer) return Boolean;
   function Set_Value(Obj: XML_Attribute; Value: Interfaces.C.Unsigned) return Boolean;
   function Set_Value(Obj: XML_Attribute; Value: Standard.Float) return Boolean;
   function Set_Value(Obj: XML_Attribute; Value: Interfaces.C.Double) return Boolean;
   function Set_Value(Obj: XML_Attribute; Value: Boolean) return Boolean;

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
