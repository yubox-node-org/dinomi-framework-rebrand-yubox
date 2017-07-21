ISONAME=output
ISODATE:=$(shell date '+%Y-%m-%d')
ISODIR:=Dinomi_Pelado_10022017
DISTRO=Dinomi

all: $(ISONAME)-$(ISODATE).iso $(ISONAME)-$(ISODATE).iso.md5sum

$(ISONAME)-$(ISODATE).iso: $(ISODIR)/ks/anaconda-ks.cfg
	genisoimage -U -r -v -T -J -joliet-long -V "CentOS 7 x86_64" \
		-volset "CentOS 7 x86_64" -A "CentOS 7 x86_64" -b isolinux/isolinux.bin \
		-c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table \
		-eltorito-alt-boot -e images/efiboot.img -no-emul-boot \
		-o $@ $(ISODIR)/

$(ISODIR)/ks/anaconda-ks.cfg: $(ISONAME)-$(ISODATE).distro-pkglist utils/anaconda-ks.cfg.half1 utils/anaconda-ks.cfg.half2
	cat utils/anaconda-ks.cfg.half1 $(ISONAME)-$(ISODATE).distro-pkglist utils/anaconda-ks.cfg.half2 > $@

$(ISONAME)-$(ISODATE).distro-pkglist:
	rpm -q --queryformat '%{NAME}\n' --package $(ISODIR)/$(DISTRO)/*rpm > $@

$(ISONAME)-$(ISODATE).iso.md5sum: $(ISONAME)-$(ISODATE).iso
	md5sum $? > $@

clean:
	rm -f *.distro-pkglist $(ISONAME)-$(ISODATE).iso $(ISONAME)-$(ISODATE).iso.md5sum
