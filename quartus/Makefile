.PHONY: quartus

quartus:
		quartus_map --read_settings_files=on --write_settings_files=off bch -c bch
		quartus_fit --read_settings_files=off --write_settings_files=off bch -c bch
		quartus_asm --read_settings_files=off --write_settings_files=off bch -c bch
		quartus_sta bch -c bch
		quartus_eda --read_settings_files=off --write_settings_files=off bch -c bch
