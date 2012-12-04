#coding:utf-8

require 'logger'
require 'date'
require 'unicode'
require 'cgi'

File.delete 'dates.error.log' if File.exists? 'dates.error.log'
File.delete 'dates.warn.log'  if File.exists? 'dates.warn.log'
File.delete 'dates.info.log'  if File.exists? 'dates.info.log'

$months = { 1 => %w(января янваяря январь янв),    2 => %w(февраля февраль февр фев), 3 => %w(марта март мар),
            4 => %w(апреля апрель апр),    5 => %w(мая май),                  6 => %w(июня июнь июн),
            7 => %w(июля июль июл),        8 => %w(августа авуста август авг),       9 => %w(сентября сентябрь сент сен),
           10 => %w(октября октябрь окт), 11 => %w(ноября ноябрь нояб ноя),  12 => %w(декабря декабрь дек) }
$noday = false
$noyear = false
$nomonth = false
$all = 0

def parse_month mon
	mmon = Unicode::downcase(mon).gsub(/\./,'')
	$months.each do |m,ms|
		return m  if ms.include? mmon
	end
	raise "ф.%s оп.%s д.%s: '" % [$fund, $list, $delo] + mon + "' - непонятный месяц"
end

def parse_date date
	$noday = false
	$noyear = false
	$nomonth = false
	dilog = Logger.new 'dates.info.log'
	if date.empty?
		$noday = true
		$noyear = true
		$nomonth = true
		return nil
	end
	md = date.strip.match /^(\d{1,2})[\/\.](\d{1,2})[\/\.]*(\d{4})$/
	md = date.strip.match /^(\d{1,2})[\/\.](\d{1,2})[\/\.](\d{2,4})$/  unless md
	if md
		begin
			yr = (md[3].to_i < 100) ? md[3].to_i + 1900 : md[3].to_i
			okdate = Date.new yr, md[2].to_i, md[1].to_i
		rescue
			raise "ф.%s оп.%s д.%s: '" % [$fund, $list, $delo] + date + "' - непонятная дата 1"
		end
		dilog.info "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + date + " =1> " + okdate.to_s
		return okdate
	end
	md = date.strip.match /^(\d{1,2})[\.\s\/]*([^\d\.\s]+)[\.\s\/]*(\d{2,4})$/
	if md
		begin
			mon = parse_month(md[2])
			yr = (md[3].to_i < 100) ? md[3].to_i + 1900 : md[3].to_i
			okdate = Date.new yr, mon, md[1].to_i
		rescue
			raise "ф.%s оп.%s д.%s: '" % [$fund, $list, $delo] + date + "' - непонятная дата 2"
		end
		dilog.info "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + date + " =2> " + okdate.to_s
		return okdate
	end
	md = date.strip.match /^([^\d\.\s]+)[\.\s\/]*(\d{2,4})$/
	md = date.strip.match /^(\d{1,2})[\.](\d{4})$/  unless md
	if md
		begin
			mon = (md[1].to_i > 0) ? md[1].to_i : parse_month(md[1])
			yr = md[2].to_i < 100 ? md[2].to_i + 1900 : md[2].to_i
			okdate = Date.new yr, mon, 1
			$noday = true
		rescue
			raise "ф.%s оп.%s д.%s: '" % [$fund, $list, $delo] + date + "' - непонятная дата 3"
		end
		dilog.info "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + date + " =3> " + okdate.to_s
		return okdate
	end
	md = date.strip.match /^(\d{4})$/
	if md
		begin
			okdate = Date.new md[1].to_i, 1, 1
			$nomonth = true
		rescue
			raise "ф.%s оп.%s д.%s: '" % [$fund, $list, $delo] + date + "' - непонятная дата 4"
		end
		dilog.info "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + date + " =4> " + okdate.to_s
		return okdate
	end
	md = date.strip.match /^(\d{1,2})$/
	if md
		begin
			okdate = Date.new 2000, 1, md[1].to_i
			$noyear = true
			$nomonth = true
		rescue
			raise "ф.%s оп.%s д.%s: '" % [$fund, $list, $delo] + date + "' - непонятная дата 5"
		end
		dilog.info "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + date + " =5> " + okdate.to_s
		return okdate
	end
	md = date.strip.match /^(\d{1,2})[\.\s\/]*([^\d\s]+)\.?$/ #/
	md = date.strip.match /^(\d{1,2})\.(\d{1,2})\.?$/  unless md
	if md
		begin
			mon = (md[2].to_i > 0) ? md[2].to_i : parse_month(md[2])
			okdate = Date.new 2000, mon, md[1].to_i
			$noyear = true
		rescue
			raise "ф.%s оп.%s д.%s: '" % [$fund, $list, $delo] + date + "' - непонятная дата 6"
		end
		dilog.info "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + date + " =6> " + okdate.to_s
		return okdate
	end
	md = date.strip.match /^([^\d\s]+)$/ #/
	if md
		begin
			mon = parse_month(md[1])
			okdate = Date.new 2000, mon, 1
			$noyear = true
			$noday = true
		rescue
			raise "ф.%s оп.%s д.%s: '" % [$fund, $list, $delo] + date + "' - непонятная дата 7"
		end
		dilog.info "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + date + " =7> " + okdate.to_s
		return okdate
	end
	return nil
end

def parse_dates date
	delog = Logger.new 'dates.error.log'
	dwlog = Logger.new 'dates.warn.log'
	ddate = Unicode::downcase date.strip
	if ddate.match(/нач(\.|ало)/) || ddate.match(/б\/д/) || ddate.match(/\d+\-е/) || ddate.match(/бе..даты/)
		delog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " допущена неточная дата '%s'" % [date]
		return ddate
	end
	if ddate.match(/^(\d)\s*квартал\s*(\d+).*/) || ddate.match(/(лето|весна|зима|осень)\s*(\d+).*/) || ddate.match(/^(до|после)\s*(\d+).*/)
		delog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " допущена неточная дата '%s'" % [date]
		return ddate
	end
	if ddate.match(/^начало\s*(\d+).*/) || ddate.match(/^середина\s*(\d+).*/) || ddate.match(/^конец\s*(\d+).*/)
		delog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " допущена неточная дата '%s'" % [date]
		return ddate
	end
	if date.match /\[(.*)\]/
		delog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " допущена дата с квадратными скобками '%s'" % [date]
		return date
	end
	
	unless date.match /^[\d\s\-\.]+$/
		delog.error "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " '#{date}': мусор в строке"
		return nil
    end
	dates = if date.match /\d\d\.\d\d\.\d\d\d\d\s+\d\d\.\d\d\.\d\d\d\d/
		date.split /\s+/
	elsif date.match /\d\d\.\d\d\.\d\d\d\d\d\d\.\d\d\.\d\d\d\d+/
		[date[0..9],date[10..19]]
	elsif date.match /\d\d\.\d\d\.\d\d\d\d+\d\d\.\d\d\.\d\d\d\d/
		[date[0..9],date[-10..-1]]
	else
		date.gsub(/\s*/,'').split /\s*-\s*/ #/
	end
	case dates.count
		when 1 then begin
			begin
				d1 = parse_date dates[0]
				d1 = nil  if $noyear
				d2 = d1
				if d1
					if d1.year < 1666 || d1.year > Date.today.year
						delog.error "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " странный год '#{date}'"
						return nil
					end
					unless (1666..2012).include? d1.year
						delog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " допущен странный год #{d1.year} '#{date}'"
					end
					if $nomonth
						d2 = (d1 >> 12) - 1
						dwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " добавлен месяц (%s => %s - %s)" % [date, d1, d2]
					elsif $noday
						d2 = (d1 >> 1) - 1
						dwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " добавлен день (%s => %s - %s)" % [date, d1, d2]
					end
				end
			rescue Exception => e
				delog.error e.message + ' [1 date]'
				return nil
			end
			unless d1
				delog.error "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " '#{date}': непонятная дата"
				return nil
			end
			return [d1, d2]
		end
		when 2 then begin
			begin
				d1 = parse_date dates[0]
				nod1d = $noday
				nod1y = $noyear
				nod1m = $nomonth
				d2 = parse_date dates[1]
				nod2d = $noday
				nod2y = $noyear
				nod2m = $nomonth
				if !d2 && !nod1y
					nod2y = false
					d2 = d1
				end
				if nod1y && nod2y
					d1 = d2 = nil
					nod1y = nod2y = false
				end
				if d1 && d2
					if d1.year < 1666 || d2.year < 1666 || d1.year > Date.today.year || d2.year > Date.today.year
						delog.error "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " странный год '#{date}'"
						return nil
					end
					unless (1666..2012).include?(d1.year) && (1666..2012).include?(d2.year)
						delog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " допущен странный год #{d1.year} #{d2.year} '#{date}'"
					end
					if $nomonth
						d2 = (d2 >> 12) - 1
						dwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " добавлены месяцы (%s => %s - %s)" % [date, d1, d2]
					elsif $noday
						if nod1y && !nod2y
							d1 = Date.new d2.year, d1.month, d1.day
		                	d2 = (d2 >> 1) - 1
							dwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " добавлены дни и годы 1 (%s => %s - %s)" % [date, d1, d2]
						elsif nod2y && !nod1y
							d2 = Date.new d1.year, d2.month, d2.day
		                	d2 = (d2 >> 1) - 1
							dwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " добавлены дни и годы 2 (%s => %s - %s)" % [date, d1, d2]
						else
		                	d2 = (d2 >> 1) - 1
							dwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + dates.inspect + " добавлены дни (%s => %s - %s)" % [date, d1, d2]
						end
					elsif nod1y
						if nod1m
							d1 = Date.new d2.year, d2.month, d1.day
							dwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " добавлен год и месяц 1 (%s => %s - %s)" % [date, d1, d2]
						else
							d1 = Date.new d2.year, d1.month, d1.day
							dwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " добавлен год 1 (%s => %s - %s)" % [date, d1, d2]
						end
					elsif nod2y
						d2 = Date.new d1.year, d2.month, d2.day
						dwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " добавлен год 2 (%s => %s - %s)" % [date, d1, d2]
					end
				end
			rescue Exception => e
				delog.error e.message + ' [2 dates]'
				return nil
			end
			unless d1
				delog.error "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " '#{date}': непонятная левая дата"
				return nil
			end
			unless d2
				delog.error "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " '#{date}': непонятная правая дата"
				return nil
			end
			if d2 < d1
				delog.error "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " '#{date}': левая дата позже, чем правая"
				return nil
				#[d1, d2]
			end
			return [d1, d2]
		end
		else begin
			$log.error "line %03d: слишком мало или много дат, должно быть 1 или 2" % $k
			return nil
		end
	end
end

def process name
	md = Unicode::downcase(name).match /ф\.\s*(.+?)[,\.]?\s*оп\.*\s*(.+?)\.rtf.*/ #/
	p name
	$fund = md[1].strip
	$list = md[2].strip
	$delo = 0

	logname = "protocol %s-%s.log" % [$fund, $list]
	File.delete logname  if File.exists? logname
	$log = Logger.new logname
	$nelog = Logger.new 'numbers.error.log'
	$nwlog = Logger.new 'numbers.warn.log'
	
	info = { :lowcols => [], :nonumber => [], :nodates => [], :nolistcount => [], :clearspace => [] }

	out = File.open("%s-%s.txt" % [$fund, $list], 'w')
	out.write "фонд %s\r\n" % $fund
	out.write "опись %s\r\n" % $list
	out.write "упр.\r\n\r\n"

	buff = ""
	File.open name, 'r:utf-8' do |src|
		buff = src.read
		buff = buff.gsub(/\n/,' ')
		buff = buff.gsub(/\[table_row_end\]/, "\n")
	end
	File.open name+'.temp', 'w' do |src|
		src.write buff
	end
	$k = 0
	$pnn = nil
	buff.each_line do |line|
		$k += 1
		cols = line.split("\t")
		dates = []
		unit = {}

		#$log << "line %03d: %d cols\n" % [$k, cn]
		if cols.count < 6
			info[:lowcols] << $k  if $k > 5
			next
		end

		unless cols[0].strip.empty?
			$log.error "line %4d: столбец 0 должен быть пустым" % $k
			next
		end
		
		nn = cols[1].gsub(/[\s \.]+/,'').strip
		$delo = nn
		if nn.to_i > 0
			if nn != nn.to_i.to_s
				unless nn.match /\d+[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя]/
					$nelog.error "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " ерунда в номере дела (%s)" % [$delo]
					next
				end
			end
		else
			info[:nonumber] << $k  if $k > 6
			next
		end
		nnn = nn.to_i
		if nn.match /\d+[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя]/
			if $pnn.to_i > 0 && nnn != $pnn.to_i
				$nwlog.info "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " дело с буквой (%s) идёт за делом с другим номером (%s)" % [$delo, $pnn]
			end
		else
			if $pnn.to_i > 0 && nnn != $pnn.to_i + 1
				$nwlog.warn "ф.%s оп.%s д.%s: " % [$fund, $list, $delo] + " дела (%s) и (%s) не по порядку" % [$delo, $pnn]
			end
		end
		$pnn = $delo
		unit[:nn] = $delo
		
		if cols[2].strip.empty?
			$log.error "line %4d: столбец 2 должен содержать строку" % $k
			next
		end
		unit[:text] = cols[2].strip.gsub(/[\s ]+/, ' ')
		shift = cols[2].strip.length - unit[:text].length
		if shift > 0
			#$log.info "line %4d: col 2 cleared of %d spaces" % [$k, shift]
			info[:clearspace] << $k
		end

		if cols[3].strip.empty?
			info[:nodates] << $k
		else
			dates = cols[3].strip
				.gsub(/ /, '')
				.gsub(/гг\./, '')
				.gsub(/г\./, '')
				.gsub(/г\-/, '-')
				.gsub(/[зЗ]/, '3')
				.gsub(/(\d)б/, '\16')
				.gsub(/[lI]/, '1')
				.gsub(/[oOоО]/, '0')
				.gsub(/[a-z]/,'')
				.gsub(/\.+$/,'')
				.gsub(/\.\s+/, '.')
				.gsub(/\s+\./, '.')
				.gsub(/\.+/, '.')
				.gsub(/\-+/, '-')
			unit[:dates] = parse_dates dates
			if unit[:dates].instance_of? Array
				unit[:d1] = unit[:dates][0].strftime("%d.%m.%Y")
				unit[:d2] = unit[:dates][1].strftime("%d.%m.%Y")
			elsif unit[:dates].instance_of? String
				unit[:ds] = unit[:dates]
			else
				next
			end
		end

		lc = cols[4].strip.to_i
		unless lc > 0
			lc = ''
			info[:nolistcount] << $k
		end
		unit[:listcount] = lc

		if cols[5].strip.empty?
			#$log.error "line %4d: столбец 5 должен содержать строку" % $k
			#next
		end
		unit[:comment] = cols[5].strip.gsub(/[\s ]+/, ' ')
		shift = cols[5].strip.length - unit[:comment].length
		if shift > 0
			#$log.info "line %4d: col 5 cleared of %d spaces" % [$k, shift]
			info[:clearspace] << $k
		end

        args = []
        args << unit[:nn]
        args << unit[:text]
        args << ( unit[:d1] && unit[:d2] ? ("%s-%s" % [unit[:d1], unit[:d2]]) : unit[:ds].to_s )
        args << unit[:listcount]
        args << unit[:comment]
		
		out.write "%s\t%s\t%s\t%s\t%s\r\n" % args
		$all += 1
	end

	out.close

	$log.warn "строки с недостаточным количеством столбцов: " + info[:lowcols].inspect
	$log.warn "строки без номера дела: " + info[:nonumber].inspect
	$log.warn "строки без крайних дат: " + info[:nodates].inspect
	$log.warn "строки без количества листов: " + info[:nolistcount].inspect
	$log.warn "строки с лишними пробелами: " + info[:clearspace].inspect

	$log.close
end

Dir.open('.').each do |name|
	process CGI.unescape(name)  if name.match /\.text$/ #/
end

p $all
File.open($all.to_s, 'w'){}
