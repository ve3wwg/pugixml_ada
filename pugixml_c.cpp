///////////////////////////////////////////////////////////////////////
// pugixml_c.cpp -- C Interface to PugiXml
// Date: Fri Jun 10 22:15:37 2016  (C) Warren W. Gay VE3WWG 
///////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include "pugixml.hpp"

extern "C" {
	unsigned c_strlen(const char *str);

	pugi::xml_document *pugi_new_xml_document();
	pugi::xml_node pugi_doc_node(pugi::xml_document *doc);
	void pugi_delete_xml_document(pugi::xml_document *doc);
	void pugi_load_xml_file(pugi::xml_document *obj,const char *pathname,int *status,unsigned *offset,int *encoding,int *ok,const char **desc);
	void pugi_load_in_place(pugi::xml_document *obj,void *content,int *status,unsigned *offset,int *encout,int *ok,const char **desc,int size,int encoding);
	int pugi_save_file(pugi::xml_document *obj,const char *pathname,const char *indent,int encoding);
	void pugi_reset(pugi::xml_document *obj);
	void pugi_reset_proto(pugi::xml_document *obj,pugi::xml_document *proto);

	int pugi_node_empty(pugi::xml_node obj);
	int pugi_node_type(pugi::xml_node obj);

	pugi::xml_node pugi_xml_child(pugi::xml_document *obj,const char *name);
	pugi::xml_node pugi_xml_parent(pugi::xml_node obj);
	pugi::xml_node pugi_node_child(pugi::xml_node obj,const char *name);
	pugi::xml_node pugi_first_child(pugi::xml_node obj);
	pugi::xml_node pugi_last_child(pugi::xml_node obj);
	pugi::xml_node pugi_doc_root(pugi::xml_document *obj);
	pugi::xml_node pugi_root_node(pugi::xml_node obj);
	pugi::xml_node pugi_next_sibling(pugi::xml_node obj);
	pugi::xml_node pugi_next_named_sibling(pugi::xml_node obj,const char *name);
	pugi::xml_node pugi_prev_sibling(pugi::xml_node obj);
	pugi::xml_node pugi_prev_named_sibling(pugi::xml_node obj,const char *name);
	const char *pugi_node_name(pugi::xml_node obj);
	const char *pugi_node_value(pugi::xml_node obj);

	const char *pugi_child_value(pugi::xml_node obj);
	const char *pugi_named_child_value(pugi::xml_node obj,const char *name);

	int pugi_set_name(pugi::xml_node obj,const char *data);
	int pugi_set_value(pugi::xml_node obj,const char *data);

	int pugi_is_eq(pugi::xml_node left,pugi::xml_node right);
	int pugi_is_lt(pugi::xml_node left,pugi::xml_node right);
	int pugi_is_le(pugi::xml_node left,pugi::xml_node right);
	int pugi_is_gt(pugi::xml_node left,pugi::xml_node right);
	int pugi_is_ge(pugi::xml_node left,pugi::xml_node right);

	pugi::xml_attribute pugi_append_attr(pugi::xml_node obj,const char *name);
	pugi::xml_attribute pugi_prepend_attr(pugi::xml_node obj,const char *name);
	pugi::xml_attribute pugi_append_after(pugi::xml_node obj,const char *name,pugi::xml_attribute attr);
	pugi::xml_attribute pugi_append_before(pugi::xml_node obj,const char *name,pugi::xml_attribute attr);

	pugi::xml_attribute pugi_append_copy(pugi::xml_node obj,pugi::xml_attribute proto);
	pugi::xml_attribute pugi_prepend_copy(pugi::xml_node obj,pugi::xml_attribute proto);
	pugi::xml_attribute pugi_insert_copy_after(pugi::xml_node obj,pugi::xml_attribute after,pugi::xml_attribute proto);
	pugi::xml_attribute pugi_insert_copy_before(pugi::xml_node obj,pugi::xml_attribute before,pugi::xml_attribute proto);

	pugi::xml_node pugi_append_child_type(pugi::xml_node obj,pugi::xml_node_type type);
	pugi::xml_node pugi_prepend_child_type(pugi::xml_node obj,pugi::xml_node_type type);
	pugi::xml_node pugi_insert_child_type_after(pugi::xml_node obj,pugi::xml_node after,pugi::xml_node_type type);
	pugi::xml_node pugi_insert_child_type_before(pugi::xml_node obj,pugi::xml_node before,pugi::xml_node_type type);

	pugi::xml_node pugi_append_child_node(pugi::xml_node obj,const char *name);
	pugi::xml_node pugi_prepend_child_node(pugi::xml_node obj,const char *name);
	pugi::xml_node pugi_insert_child_node_after(pugi::xml_node obj,pugi::xml_node after,const char *name);
	pugi::xml_node pugi_insert_child_node_before(pugi::xml_node obj,pugi::xml_node before,const char *name);

	pugi::xml_node pugi_append_copy_node(pugi::xml_node obj,pugi::xml_node proto);
	pugi::xml_node pugi_prepend_copy_node(pugi::xml_node obj,pugi::xml_node proto);
	pugi::xml_node pugi_insert_copy_node_after(pugi::xml_node obj,pugi::xml_node after,pugi::xml_node proto);
	pugi::xml_node pugi_insert_copy_node_before(pugi::xml_node obj,pugi::xml_node before,pugi::xml_node proto);

	pugi::xml_node pugi_find_by_path(pugi::xml_node obj,const char *path,char delimiter);

	int pugi_remove_attr(pugi::xml_node obj,pugi::xml_attribute attr);
	int pugi_remove_attr_name(pugi::xml_node obj,const char *name);
	int pugi_remove_child(pugi::xml_node obj,pugi::xml_node child);
	int pugi_remove_child_name(pugi::xml_node obj,const char *name);

	pugi::xml_attribute pugi_first_attr(pugi::xml_node obj);
	pugi::xml_attribute pugi_last_attr(pugi::xml_node obj);
	pugi::xml_attribute pugi_attr(pugi::xml_node obj,const char *name);

	const char *pugi_attr_name(pugi::xml_attribute obj);
	const char *pugi_attr_value(pugi::xml_attribute obj);

	const char *pugi_text(pugi::xml_node obj);

	int pugi_attr_empty(pugi::xml_attribute obj);

	int pugi_is_attr_eq(pugi::xml_attribute left,pugi::xml_attribute right);
	int pugi_is_attr_lt(pugi::xml_attribute left,pugi::xml_attribute right);
	int pugi_is_attr_le(pugi::xml_attribute left,pugi::xml_attribute right);
	int pugi_is_attr_gt(pugi::xml_attribute left,pugi::xml_attribute right);
	int pugi_is_attr_ge(pugi::xml_attribute left,pugi::xml_attribute right);

	pugi::xml_attribute pugi_next_attr(pugi::xml_attribute obj);
	pugi::xml_attribute pugi_prev_attr(pugi::xml_attribute obj);

	int pugi_attr_as_int(pugi::xml_attribute obj);
	unsigned pugi_attr_as_uint(pugi::xml_attribute obj);
	float pugi_attr_as_float(pugi::xml_attribute obj);
	double pugi_attr_as_double(pugi::xml_attribute obj);
	int pugi_attr_as_bool(pugi::xml_attribute obj);

	void pugi_set_attr_name(pugi::xml_attribute obj,const char *name);
	void pugi_set_attr_value(pugi::xml_attribute obj,const char *value);
	void pugi_set_attr_int(pugi::xml_attribute obj,int value);
	void pugi_set_attr_uint(pugi::xml_attribute obj,unsigned value);
	void pugi_set_attr_float(pugi::xml_attribute obj,float value);
	void pugi_set_attr_double(pugi::xml_attribute obj,double value);
	void pugi_set_attr_bool(pugi::xml_attribute obj,int value);
}

pugi::xml_document *
pugi_new_xml_document() {
	assert(sizeof(pugi::xml_node) == sizeof(void*));
	assert(sizeof(pugi::xml_attribute) == sizeof(void*));
	return new pugi::xml_document();
}

void
pugi_delete_xml_document(pugi::xml_document *obj) {
	delete obj;
}

void
pugi_load_xml_file(pugi::xml_document *obj,const char *pathname,int *status,unsigned *offset,int *encoding,int *ok,const char **desc) {
	
	pugi::xml_parse_result r = obj->load_file(pathname);
	*status = int(r.status);
	*offset = r.offset;
	*encoding = int(r.encoding);
	*ok = bool(r) ? 1 : 0;
	*desc = r.description();
}

void
pugi_load_in_place(pugi::xml_document *obj,void *content,int *status,unsigned *offset,int *encout,int *ok,const char **desc,int size,int encoding) {
	
	pugi::xml_parse_result r = obj->load_buffer_inplace(content,size_t(size),pugi::parse_default,pugi::xml_encoding(encoding));
	*status = int(r.status);
	*offset = r.offset;
	*encout = int(r.encoding);
	*ok = bool(r) ? 1 : 0;
	*desc = r.description();
}

int
pugi_save_file(pugi::xml_document *obj,const char *pathname,const char *indent,int encoding) {
	return obj->save_file(pathname,indent,pugi::xml_encoding(encoding)) ? 1 : 0;
}

void
pugi_reset(pugi::xml_document *obj) {
	obj->reset();
}

void
pugi_reset_proto(pugi::xml_document *obj,pugi::xml_document *proto) {
	obj->reset(*proto);
}

pugi::xml_node
pugi_doc_node(pugi::xml_document *doc) {
	return doc->document_element();
}

pugi::xml_node
pugi_xml_child(pugi::xml_document *doc,const char *name) {
	return doc->child(name);
}

const char *
pugi_node_name(pugi::xml_node xml_node) {

	return xml_node.name();
}

const char *
pugi_node_value(pugi::xml_node xml_node) {

	return xml_node.value();
}

pugi::xml_node 
pugi_xml_parent(pugi::xml_node obj) {
	return obj.parent();
}

pugi::xml_node
pugi_node_child(pugi::xml_node obj,const char *name) {

	return obj.child(name);
}

int
pugi_node_empty(pugi::xml_node obj) {
	return obj.empty() ? 1 : 0;
}

int
pugi_node_type(pugi::xml_node obj) {
	return obj.type();
}

pugi::xml_node
pugi_first_child(pugi::xml_node obj) {
	return obj.first_child();
}

pugi::xml_node 
pugi_last_child(pugi::xml_node obj) {
	return obj.last_child();
}

pugi::xml_node
pugi_doc_root(pugi::xml_document *obj) {
	return obj->root();
}

pugi::xml_node 
pugi_root_node(pugi::xml_node obj) {
	return obj.root();
}

pugi::xml_node
pugi_next_sibling(pugi::xml_node obj) {
	return obj.next_sibling();
}

pugi::xml_node
pugi_next_named_sibling(pugi::xml_node obj,const char *name) {
	return obj.next_sibling(name);
}

pugi::xml_node
pugi_prev_sibling(pugi::xml_node obj) {
	return obj.previous_sibling();
}

pugi::xml_node
pugi_prev_named_sibling(pugi::xml_node obj,const char *name) {
	return obj.previous_sibling(name);
}

const char *
pugi_child_value(pugi::xml_node obj) {
	return obj.child_value();
}

const char *
pugi_named_child_value(pugi::xml_node obj,const char *name) {
	return obj.child_value(name);
}

int
pugi_set_name(pugi::xml_node obj,const char *data) {
	return obj.set_name(data) ? 1 : 0;
}

int
pugi_set_value(pugi::xml_node obj,const char *data) {
	return obj.set_value(data) ? 1 : 0;
}

int
pugi_is_eq(pugi::xml_node left,pugi::xml_node right) {
	return left == right ? 1 : 0;
}

int
pugi_is_lt(pugi::xml_node left,pugi::xml_node right) {
	return left < right ? 1 : 0;
}

int
pugi_is_le(pugi::xml_node left,pugi::xml_node right) {
	return left <= right ? 1 : 0;
}

int
pugi_is_gt(pugi::xml_node left,pugi::xml_node right) {
	return left > right ? 1 : 0;
}

int
pugi_is_ge(pugi::xml_node left,pugi::xml_node right) {
	return left >= right ? 1 : 0;
}

pugi::xml_attribute
pugi_first_attr(pugi::xml_node obj) {
	return obj.first_attribute();
}

pugi::xml_attribute
pugi_last_attr(pugi::xml_node obj) {
	return obj.last_attribute();
}

pugi::xml_attribute
pugi_attr(pugi::xml_node obj,const char *name) {
	return obj.attribute(name);
}

const char *
pugi_attr_name(pugi::xml_attribute obj) {
	return obj.name();
}

const char *
pugi_attr_value(pugi::xml_attribute obj) {
	return obj.value();
}

const char *
pugi_text(pugi::xml_node obj) {
	return obj.text().get();
}

int
pugi_attr_empty(pugi::xml_attribute obj) {
	return obj.empty();
}

int
pugi_is_attr_eq(pugi::xml_attribute left,pugi::xml_attribute right) {
	return left == right;
}

int
pugi_is_attr_lt(pugi::xml_attribute left,pugi::xml_attribute right) {
	return left < right;
}

int
pugi_is_attr_le(pugi::xml_attribute left,pugi::xml_attribute right) {
	return left <= right;
}

int
pugi_is_attr_gt(pugi::xml_attribute left,pugi::xml_attribute right) {
	return left > right;
}

int
pugi_is_attr_ge(pugi::xml_attribute left,pugi::xml_attribute right) {
	return left >= right;
}

pugi::xml_attribute
pugi_append_attr(pugi::xml_node obj,const char *name) {
	return obj.append_attribute(name);
}

pugi::xml_attribute
pugi_prepend_attr(pugi::xml_node obj,const char *name) {
	return obj.prepend_attribute(name);
}

pugi::xml_attribute
pugi_append_after(pugi::xml_node obj,const char *name,pugi::xml_attribute other) {
	return obj.insert_attribute_after(name,other);
}

pugi::xml_attribute
pugi_append_before(pugi::xml_node obj,const char *name,pugi::xml_attribute other) {
	return obj.insert_attribute_before(name,other);
}

pugi::xml_attribute
pugi_next_attr(pugi::xml_attribute obj) {
	return obj.next_attribute();
}

pugi::xml_attribute
pugi_prev_attr(pugi::xml_attribute obj) {
	return obj.previous_attribute();
}

pugi::xml_attribute
pugi_append_copy(pugi::xml_node obj,pugi::xml_attribute proto) {
      return obj.append_copy(proto);
}

pugi::xml_attribute
pugi_prepend_copy(pugi::xml_node obj,pugi::xml_attribute proto) {
      return obj.prepend_copy(proto);
}

pugi::xml_attribute
pugi_insert_copy_after(pugi::xml_node obj,pugi::xml_attribute after,pugi::xml_attribute proto) {
      return obj.insert_copy_after(proto,after);
}

pugi::xml_attribute
pugi_insert_copy_before(pugi::xml_node obj,pugi::xml_attribute before,pugi::xml_attribute proto) {
      return obj.insert_copy_before(proto,before);
}

pugi::xml_node
pugi_append_child_type(pugi::xml_node obj,pugi::xml_node_type type) {
	return obj.append_child(type);
}

pugi::xml_node
pugi_prepend_child_type(pugi::xml_node obj,pugi::xml_node_type type) {
	return obj.prepend_child(type);
}

pugi::xml_node
pugi_insert_child_type_after(pugi::xml_node obj,pugi::xml_node after,pugi::xml_node_type type) {
	return obj.insert_child_after(type,after);
}

pugi::xml_node
pugi_insert_child_type_before(pugi::xml_node obj,pugi::xml_node before,pugi::xml_node_type type) {
	return obj.insert_child_before(type,before);
}

pugi::xml_node
pugi_append_child_node(pugi::xml_node obj,const char *name) {
	return obj.append_child(name);
}

pugi::xml_node
pugi_prepend_child_node(pugi::xml_node obj,const char *name) {
	return obj.prepend_child(name);
}

pugi::xml_node
pugi_insert_child_node_after(pugi::xml_node obj,pugi::xml_node after,const char *name) {
	return obj.insert_child_after(name,after);
}

pugi::xml_node
pugi_insert_child_node_before(pugi::xml_node obj,pugi::xml_node before,const char *name) {
	return obj.insert_child_after(name,before);
}

pugi::xml_node 
pugi_append_copy_node(pugi::xml_node obj,pugi::xml_node proto) {
	return obj.append_copy(proto);
}

pugi::xml_node 
pugi_prepend_copy_node(pugi::xml_node obj,pugi::xml_node proto) {
	return obj.prepend_copy(proto);
}

pugi::xml_node 
pugi_insert_copy_node_after(pugi::xml_node obj,pugi::xml_node after,pugi::xml_node proto) {
	return obj.insert_copy_after(proto,after);
}

pugi::xml_node 
pugi_insert_copy_node_before(pugi::xml_node obj,pugi::xml_node before,pugi::xml_node proto) {
	return obj.insert_copy_before(proto,before);
}

int
pugi_remove_attr(pugi::xml_node obj,pugi::xml_attribute attr) {
	return obj.remove_attribute(attr) ? 1 : 0;
}

int
pugi_remove_attr_name(pugi::xml_node obj,const char *name) {
	return obj.remove_attribute(name) ? 1 : 0;
}

int
pugi_remove_child(pugi::xml_node obj,pugi::xml_node child) {
	return obj.remove_child(child);
}

int
pugi_remove_child_name(pugi::xml_node obj,const char *name) {
	return obj.remove_child(name);
}

pugi::xml_node
pugi_find_by_path(pugi::xml_node obj,const char *path,char delimiter) {
	return obj.first_element_by_path(path,delimiter);
}

int
pugi_attr_as_int(pugi::xml_attribute obj) {
	return obj.as_int();
}

unsigned
pugi_attr_as_uint(pugi::xml_attribute obj) {
	return obj.as_uint();
}

float
pugi_attr_as_float(pugi::xml_attribute obj) {
	return obj.as_float();
}

double
pugi_attr_as_double(pugi::xml_attribute obj) {
	return obj.as_double();
}

int
pugi_attr_as_bool(pugi::xml_attribute obj) {
	return obj.as_bool() ? 1 : 0;
}

void 
pugi_set_attr_name(pugi::xml_attribute obj,const char *name) {
	obj.set_name(name);
}

void 
pugi_set_attr_value(pugi::xml_attribute obj,const char *value) {
	obj.set_value(value);
}

void 
pugi_set_attr_int(pugi::xml_attribute obj,int value) {
	obj.set_value(value);
}

void 
pugi_set_attr_uint(pugi::xml_attribute obj,unsigned value) {
	obj.set_value(value);
}

void 
pugi_set_attr_float(pugi::xml_attribute obj,float value) {
	obj.set_value(value);
}

void 
pugi_set_attr_double(pugi::xml_attribute obj,double value) {
	obj.set_value(value);
}

void 
pugi_set_attr_bool(pugi::xml_attribute obj,int value) {
	obj.set_value(value != 0);
}

unsigned
c_strlen(const char *str) {
	return unsigned(strlen(str));
}

// End pugixml_c.cpp
