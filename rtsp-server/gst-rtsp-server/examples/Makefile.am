noinst_PROGRAMS = launch

#INCLUDES = -I$(top_srcdir) -I$(srcdir)

AM_CFLAGS = $(GST_OBJ_CFLAGS)
LDADD = $(GST_OBJ_LIBS) $(GIO_LIBS)

if HAVE_LIBCGROUP
noinst_PROGRAMS += test-cgroups
LDADD += $(LIBCGROUP_LIBS)
endif

