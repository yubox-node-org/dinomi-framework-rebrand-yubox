ISONAME=output
ISODATE:=$(shell date '+%Y-%m-%d')
ISODIR:=Dinomi_Pelado_10022017

all: $(ISONAME)-$(ISODATE).iso $(ISONAME)-$(ISODATE).iso.md5sum

$(ISONAME)-$(ISODATE).iso:
	genisoimage -U -r -v -T -J -joliet-long -V "CentOS 7 x86_64" \
		-volset "CentOS 7 x86_64" -A "CentOS 7 x86_64" -b isolinux/isolinux.bin \
		-c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table \
		-eltorito-alt-boot -e images/efiboot.img -no-emul-boot \
		-o $@ $(ISODIR)/

$(ISONAME)-$(ISODATE).iso.md5sum: $(ISONAME)-$(ISODATE).iso
	md5sum $? > $@
