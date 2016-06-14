######################################################################
#  Makefile
######################################################################

include Makefile.incl

all:	xrm pugitest

OBJS	= ansi-c-lex.o ansi-c-yacc.o pugixml.o main.o config.o utils.o comp.o \
	  macros.o types.o sect2.o btypes.o systypes.o structs.o

main:	ansi-c-lex.cpp ansi-c-yacc.cpp $(OBJS)
	$(CXX) $(OBJS) -o main
	rm -f atest atest.o *.ali b~* cglue.o

pugi_xml.o:
	$(GNAT) -c -gnata pugi_xml.adb
	
pugitest: pugixml_c.o pugi_xml.o pugixml.o
	$(GNAT) -g -gnata pugitest pugi_xml -largs pugixml_c.o pugixml.o --LINK=g++

xrm:
	rm -f pugixml_c.o pugi_xml.o

clean:
	rm -f *.o *.ali core .errs.t out.xml
	rm -f t[0-9][0-9][0-9][0-9]

clobber: clean
	rm -f b~* *.ali core* pugitest

distclean: clobber

# End Makefile
