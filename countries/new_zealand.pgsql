------------------------------------------
------------------------------------------
-- <country> Holidays
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.country(p_start_year INTEGER, p_end_year INTEGER)
RETURNS SETOF holidays.holiday
AS $$

DECLARE
	-- Month Constants
	JANUARY INTEGER := 1;
	FEBRUARY INTEGER := 2;
	MARCH INTEGER := 3;
	APRIL INTEGER := 4;
	MAY INTEGER := 5;
	JUNE INTEGER := 6;
	JULY INTEGER := 7;
	AUGUST INTEGER := 8;
	SEPTEMBER INTEGER := 9;
	OCTOBER INTEGER := 10;
	NOVEMBER INTEGER := 11;
	DECEMBER INTEGER := 12;
	-- Weekday Constants
	SUNDAY INTEGER := 0;
	MONDAY INTEGER := 1;
	TUESDAY INTEGER := 2;
	WEDNESDAY INTEGER := 3;
	THURSDAY INTEGER := 4;
	FRIDAY INTEGER := 5;
	SATURDAY INTEGER := 6;
	WEEKEND INTEGER[] := ARRAY[0, 6];
	-- Provinces
	PROVINCES = ['NTL', 'AUK', 'TKI', 'HKB', 'WGN', 'MBH', 'NSN', 'CAN',
				 'STC', 'WTL', 'OTA', 'STL', 'CIT']
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_dt1 DATE;
	t_dt2 DATE;
	t_holiday holidays.holiday%rowtype;

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP

		-- Bank Holidays Act 1873
		-- The Employment of Females Act 1873
		-- Factories Act 1894
		-- Industrial Conciliation and Arbitration Act 1894
		-- Labour Day Act 1899
		-- Anzac Day Act 1920, 1949, 1956
		-- New Zealand Day Act 1973
		-- Waitangi Day Act 1960, 1976
		-- Sovereign's Birthday Observance Act 1937, 1952
		-- Holidays Act 1981, 2003
		IF t_year < 1894 THEN
			return

		-- New Year's Day
		t_holiday.description := 'New Year''s Day';
		jan1 = date(year, JANUARY, 1)
		self[jan1] = name
		IF jan1.weekday() in WEEKEND THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 3);
			RETURN NEXT t_holiday; + ' (Observed)'

		t_holiday.description := 'Day after New Year''s Day';
		jan2 = date(year, JANUARY, 2)
		self[jan2] = name
		IF jan2.weekday() in WEEKEND THEN
			t_holiday.datestamp := make_date(t_year, JANUARY, 4);
			RETURN NEXT t_holiday; + ' (Observed)'

		-- Waitangi Day
		IF t_year > 1973 THEN
			t_holiday.description := 'New Zealand Day';
			IF t_year > 1976 THEN
				t_holiday.description := 'Waitangi Day';
			feb6 = date(year, FEB, 6)
			self[feb6] = name
			IF t_year >= 2014 and feb6.weekday() in WEEKEND THEN
				self[feb6 + rd(weekday=MO)] = name + ' (Observed)'

		-- Easter
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), FR, -1);
		t_holiday.description := 'Good Friday';
		RETURN NEXT t_holiday;
		t_holiday.datestamp := holidays.find_nth_weekday_date(holidays.easter(t_year), MONDAY, 1);
		t_holiday.description := 'Easter Monday';
		RETURN NEXT t_holiday;

		-- Anzac Day
		IF t_year > 1920 THEN
			t_holiday.description := 'Anzac Day';
			apr25 = date(year, APR, 25)
			self[apr25] = name
			IF t_year >= 2014 and apr25.weekday() in WEEKEND THEN
				self[apr25 + rd(weekday=MO)] = name + ' (Observed)'

		-- Sovereign's Birthday
		IF t_year >= 1952 THEN
			t_holiday.description := 'Queen''s Birthday';
		ELSIF t_year > 1901 THEN
			t_holiday.description := 'King''s Birthday';
		IF t_year == 1952 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 2);
			RETURN NEXT t_holiday;  -- Elizabeth II
		ELSIF t_year > 1937 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, JUNE, 1), MO, +1);
			t_holiday.description = name  -- EII & GVI;
			RETURN NEXT t_holiday;
		ELSIF t_year == 1937 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 9);
			RETURN NEXT t_holiday;  -- George VI
		ELSIF t_year == 1936 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 23);
			RETURN NEXT t_holiday;  -- Edward VIII
		ELSIF t_year > 1911 THEN
			t_holiday.datestamp := make_date(t_year, JUNE, 3);
			RETURN NEXT t_holiday;  -- George V
		ELSIF t_year > 1901 THEN
			-- http://paperspast.natlib.govt.nz/cgi-bin/paperspast?a=d&d=NZH19091110.2.67
			t_holiday.datestamp := make_date(t_year, NOVEMBER, 9);
			RETURN NEXT t_holiday;  -- Edward VII

		-- Labour Day
		t_holiday.description := 'Labour Day';
		IF t_year >= 1910 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MO, +4);
			t_holiday.description = name;
			RETURN NEXT t_holiday;
		ELSIF t_year > 1899 THEN
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, OCTOBER, 1), WE, +2);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		-- Christmas Day
		t_holiday.description := 'Christmas Day';
		dec25 = date(year, DECEMBER, 25)
		self[dec25] = name
		IF dec25.weekday() in WEEKEND THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 27);
			RETURN NEXT t_holiday; + ' (Observed)'

		-- Boxing Day
		t_holiday.description := 'Boxing Day';
		dec26 = date(year, DECEMBER, 26)
		self[dec26] = name
		IF dec26.weekday() in WEEKEND THEN
			t_holiday.datestamp := make_date(t_year, DECEMBER, 28);
			RETURN NEXT t_holiday; + ' (Observed)'

		-- Province Anniversary Day
		IF self.prov in ('NTL', 'Northland', 'AUK', 'Auckland') THEN
			IF 1963 < year <= 1973 and self.prov in ('NTL', 'Northland') THEN
				t_holiday.description := 'Waitangi Day';
				dt = date(year, FEB, 6)
			ELSE
				t_holiday.description := 'Auckland Anniversary Day';
				dt = date(year, JANUARY, 29)
			IF dt.weekday() in (TUE, WED, THU) THEN
				self[dt + rd(weekday=MO(-1))] = name
			ELSE
				self[dt + rd(weekday=MO)] = name

		elIF self.prov in ('TKI', 'Taranaki', 'New Plymouth') THEN
			t_holiday.description := 'Taranaki Anniversary Day';
			t_holiday.datestamp = find_nth_weekday_date(make_date(t_year, MAR, 1), MO, +2);
			t_holiday.description = name;
			RETURN NEXT t_holiday;

		elIF self.prov in ('HKB', 'Hawke''s Bay') THEN
			t_holiday.description := 'Hawke''s Bay Anniversary Day';
			labour_day = find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MO, +4);
			self[labour_day + rd(weekday=FR(-1))] = name

		elIF self.prov in ('WGN', 'Wellington') THEN
			t_holiday.description := 'Wellington Anniversary Day';
			jan22 = date(year, JANUARY, 22)
			IF jan22.weekday() in (TUE, WED, THU) THEN
				self[jan22 + rd(weekday=MO(-1))] = name
			ELSE
				self[jan22 + rd(weekday=MO)] = name

		elIF self.prov in ('MBH', 'Marlborough') THEN
			t_holiday.description := 'Marlborough Anniversary Day';
			labour_day = find_nth_weekday_date(make_date(t_year, OCTOBER, 1), MO, +4);
			self[labour_day + rd(weeks=1)] = name

		elIF self.prov in ('NSN', 'Nelson') THEN
			t_holiday.description := 'Nelson Anniversary Day';
			feb1 = date(year, FEB, 1)
			IF feb1.weekday() in (TUE, WED, THU) THEN
				self[feb1 + rd(weekday=MO(-1))] = name
			ELSE
				self[feb1 + rd(weekday=MO)] = name

		elIF self.prov in ('CAN', 'Canterbury') THEN
			t_holiday.description := 'Canterbury Anniversary Day';
			showday = date(year, NOVEMBER, 1) + rd(weekday=TU) + rd(weekday=FR(+2))
			self[showday] = name

		elIF self.prov in ('STC', 'South Canterbury') THEN
			t_holiday.description := 'South Canterbury Anniversary Day';
			dominion_day = find_nth_weekday_date(make_date(t_year, SEPTEMBER, 1), MO, 4);
			self[dominion_day] = name

		elIF self.prov in ('WTL', 'Westland') THEN
			t_holiday.description := 'Westland Anniversary Day';
			dec1 = date(year, DECEMBER, 1)
			-- Observance varies?!?!
			IF t_year == 2005 THEN  -- special case?!?!
				t_holiday.datestamp := make_date(t_year, DECEMBER, 5);
				RETURN NEXT t_holiday;
			elIF dec1.weekday() in (TUE, WED, THU) THEN
				self[dec1 + rd(weekday=MO(-1))] = name
			ELSE
				self[dec1 + rd(weekday=MO)] = name

		elIF self.prov in ('OTA', 'Otago') THEN
			t_holiday.description := 'Otago Anniversary Day';
			mar23 = date(year, MAR, 23)
			-- there is no easily determined single day of local observance?!?!
			IF mar23.weekday() in (TUE, WED, THU) THEN
				dt = mar23 + rd(weekday=MO(-1))
			ELSE
				dt = mar23 + rd(weekday=MO)
			IF dt == easter(year) + rd(weekday=MO) THEN  -- Avoid Easter Monday
				dt += rd(days=1)
			self[dt] = name

		elIF self.prov in ('STL', 'Southland') THEN
			t_holiday.description := 'Southland Anniversary Day';
			jan17 = date(year, JANUARY, 17)
			IF t_year > 2011 THEN
				self[easter(year) + rd(weekday=TU)] = name
			ELSE
				IF jan17.weekday() in (TUE, WED, THU) THEN
					self[jan17 + rd(weekday=MO(-1))] = name
				ELSE
					self[jan17 + rd(weekday=MO)] = name

		elIF self.prov in ('CIT', 'Chatham Islands') THEN
			t_holiday.description := 'Chatham Islands Anniversary Day';
			nov30 = date(year, NOVEMBER, 30)
			IF nov30.weekday() in (TUE, WED, THU) THEN
				self[nov30 + rd(weekday=MO(-1))] = name
			ELSE
				self[nov30 + rd(weekday=MO)] = name

	END LOOP;
END;

$$ LANGUAGE plpgsql;