######################################################################
#  Makefile
######################################################################

include Makefile.incl

all:	libpugixml_ada.a pugitest pugidemo
	@echo "Run ./pugitest for a grotty simple test of basic XML functions."
	@echo
	@echo "Run ./pugidemo to create and process testconfig.xml."
	@echo "See program pugidemo.adb for example code."

pugi_xml.o:
	$(GNAT) -c -gnata pugi_xml.adb
	
libpugixml_ada.a: pugi_xml.o pugixml_c.o pugixml.o
	$(AR) r libpugixml_ada.a pugi_xml.o pugixml_c.o pugixml.o

pugitest: libpugixml_ada.a pugitest.adb
	$(GNAT) -g -gnata pugitest -largs -L. -lpugixml_ada --LINK=g++

pugidemo: libpugixml_ada.a pugidemo.adb
	$(GNAT) -g -gnata pugidemo -largs -L. -lpugixml_ada --LINK=g++

xrm:
	rm -f pugixml_c.o pugi_xml.o

clean:
	rm -f *.o *.ali core .errs.t out.xml
	rm -f t[0-9][0-9][0-9][0-9]

clobber: clean
	rm -f b~* *.ali *.a core* pugitest pugidemo testconfig.xml

distclean: clobber

pugixml_c.o: pugixml.hpp pugixml.cpp
pugi_xml.o: pugi_xml.ads pugi_xml.adb
pugitest.o: pugitest.adb
pugidemo.o: pugidemo.adb

# End Makefile
