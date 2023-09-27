#Использовать "C:\Program Files\OneScript\lib\opm\oscript_modules\json" 

Функция СтрокаПодключенияРесуса(Параметры)  
	ПодключениеРесурса = 
		"net use z: \\pc\common /user:mike 1234" ;

	Ответ = "net use Y: " 
	+ Параметры.Ресурс
	+ " /USER:" 
	+ Параметры.Пользователь 
	+ " " 
	+ Параметры.Пароль ;

	Возврат Ответ ; 

КонецФункции 
Функция ПрочитатьКонфигурацию(ИмяФайлаКлюча)
	Текст = Новый ТекстовыйДокумент ;
	Текст.Прочитать(ИмяФайлаКлюча) ;
	ИсхСтрока = "";
	
	Для н =1 по Текст.КоличествоСтрок() Цикл 
		ИсхСтрока = ИсхСтрока + Текст.ПолучитьСтроку(н);
	КонецЦикла ;
	
	ДД = Base64Значение(ИсхСтрока) ;
	ИмяВремФайла = ПолучитьИмяВременногоФайла("cfg") ;
	ДД.Записать(ИмяВремФайла);
	
	Текст = Новый ЧтениеТекста ;
	Текст.Открыть(ИмяВремФайла);
	СтрокаКонф =  Текст.Прочитать() ;
	Текст.Закрыть();
	УдалитьФайлы(ИмяВремФайла) ;

//	Сообщить(СтрокаКонф);
	ПарсерJSON = Новый ПарсерJSON();
	Конф = ПарсерJSON.ПрочитатьJSON(СтрокаКонф,,,Истина) ;
	Сообщить(ТипЗнч(Конф));


КонецФункции 

Функция УдалитьПрочитатьКонфигурацию(ИмяФайлаКлюча)
	Текст = Новый ТекстовыйДокумент ;
	Текст.Прочитать(ИмяФайлаКлюча) ;
	ИсхСтрока = "";
	
	Для н =1 по Текст.КоличествоСтрок() Цикл 
		ИсхСтрока = ИсхСтрока + Текст.ПолучитьСтроку(н);
	КонецЦикла ;
	
	ДД = Base64Значение(ИсхСтрока) ;
	ИмяВремФайла = ПолучитьИмяВременногоФайла("cfg") ;
	ДД.Записать(ИмяВремФайла);
	
	Текст.Прочитать(ИмяВремФайла) ;
	УдалитьФайлы(ИмяВремФайла) ;

	ПараметрыРесураса = Новый Структура ;
	ПараметрыРесураса.Вставить("Ресурс",Текст.ПолучитьСтроку(1));
	ПараметрыРесураса.Вставить("Пользователь",Текст.ПолучитьСтроку(2));
	ПараметрыРесураса.Вставить("Пароль",Текст.ПолучитьСтроку(3));
	СтрокаПодключенияРесуса = СтрокаПодключенияРесуса(ПараметрыРесураса) ;
//	Сообщить(СтрокаПодключенияРесуса) ;	

	Ответ = Новый Структура ; 
	Ответ.вставить("ПодключениеРесурса",СтрокаПодключенияРесуса) ;
	Ответ.вставить("Источник",Текст.ПолучитьСтроку(4)) ;
	Ответ.вставить("Назначение",Текст.ПолучитьСтроку(5));

	Маски = Новый Массив ;

	Для н = 6 по Текст.КоличествоСтрок() Цикл
		НоваяМаска = Текст.ПолучитьСтроку(н);
		Маски.Добавить(НоваяМаска);	
		
	КонецЦикла ;

	Ответ.Вставить("Маски",Маски);

	Возврат Ответ ;

КонецФункции 

Процедура ОбработатьФайлы(Конфигурация)

	ЗапуститьПриложение(Конфигурация.ПодключениеРесурса,,Истина);
	Источник = Конфигурация.Источник  ;
	Назначение = Конфигурация.Назначение  ;
	Для каждого Маска из Конфигурация.Маски Цикл 
		МассивПеренесенных = Новый Массив ;
		Файлы = НайтиФайлы(Источник,Маска) ;

		Для каждого ФайлИсточник из Файлы Цикл 
			МассивПеренесенных.Добавить(ФайлИсточник.Имя);
			ИмяФайлаНазначения = Назначение + ФайлИсточник.Имя;
			ФайлНазначение = Новый Файл(ИмяФайлаНазначения);
		//	Сообщить(Назначение);	
			Если Не ФайлНазначение.Существует() Тогда 
				КопироватьФайл(ФайлИсточник.ПолноеИмя , ИмяФайлаНазначения) ;
				Сообщить("Копируем " + ИмяФайлаНазначения);	
			Иначе
				Сообщить("Уже есть " +ИмяФайлаНазначения);	
			КонецЕсли ;

	 	КонецЦикла ;
		ФайлыДляЧистки = НайтиФайлы(Назначение,Маска);
		
		Для каждого ФайлДляПроверки Из ФайлыДляЧистки Цикл
			
			Если МассивПеренесенных.Найти(ФайлДляПроверки.Имя) = Неопределено Тогда 
				Сообщить("Нужно удалить " +ФайлДляПроверки.Имя  );				
				Сообщить("Удаляем " + ФайлДляПроверки.ПолноеИмя );	
				УдалитьФайлы(ФайлДляПроверки.ПолноеИмя);			
			КонецЕсли ;

		КонецЦикла; 
	КонецЦикла ;

КонецПроцедуры
/////////////////////////////////////////
Процедура КодированиеРесурса(ИмяФайла,ИмяКонечногоФайла)

	ДД = Новый  ДвоичныеДанные(ИмяФайла);
	Ответ = Новый ТекстовыйДокумент ;

	РезультатКодирования = Base64Строка(ДД) ;
	ДлинаСтроки = СтрДлина(РезультатКодирования) ;
	ДлинаВКлюче = 32 ;
	н =1 ;
	
	Пока Истина Цикл
		НачПоз = (н-1)*ДлинаВКлюче +1 ;
		КонПоз = НачПоз +ДлинаВКлюче ;
		Если НачПоз > ДлинаСтроки Тогда 
			Прервать ;
		КонецЕсли ;

		Данные = Сред(РезультатКодирования,НачПоз,ДлинаВКлюче) ;
		Если СтрДлина(Данные) > 0 Тогда 
			Ответ.ДобавитьСтроку(Данные) ;
		КонецЕсли ;
		Если КонПоз > ДлинаСтроки Тогда 
			Прервать ;
		КонецЕсли ;
		н = н+1 ; 
	КонецЦикла ;
	Ответ.Записать(ИмяКонечногоФайла) ;
КонецПроцедуры 	

/////////////////////////////////////////

Функция СтрокаРесурсаРаскодирование(ИсходнаяСтрока)
	Текст = Новый ТекстовыйДокумент;
	ИмяВремФайла = ПолучитьИмяВременногоФайла("txt") ;

	ДДНов = Base64Значение(ИсходнаяСтрока) ;
	ДДНов.Записать(ИмяВремФайла);
	Текст.Прочитать(ИмяВремФайла);
	Ответ  = Текст.ПолучитьСтроку(1) ;

	УдалитьФайлы(ИмяВремФайла);
	Возврат Ответ ;

КонецФункции  	

Процедура СоздатьФайлКонфигурации(ИмяФайлаКонфигурации) 

	КонфигурацияСетевойДиск = Новый Структура  ;
	КонфигурацияСетевойДиск.Вставить("Подключить",Ложь) ;
	КонфигурацияСетевойДиск.Вставить("БукваДиска","Z") ;
	КонфигурацияСетевойДиск.Вставить("СетевойКаталог","\\server") ;
	КонфигурацияСетевойДиск.Вставить("Пользователь","user") ;
	КонфигурацияСетевойДиск.Вставить("Пароль","123") ;

	Конфигурация = Новый Структура  ;
	Конфигурация.Вставить("ФайлИсточник","c:\temp\1cv8.1cd");
	Конфигурация.Вставить("Упаковка",Истина);
	Конфигурация.Вставить("ПутьИсточника","c:\temp");
	Конфигурация.Вставить("ПутьНазначения","c:\temp1");
	Конфигурация.Вставить("КомандаСистемыДоКопирования","") ;
	Конфигурация.Вставить("КомандаСистемыПослеКопирования","") ;
	Конфигурация.Вставить("КоличествоКопий",10) ;
	Конфигурация.Вставить("МаскаФайлов","*.zip") ;
	Конфигурация.Вставить("СетевойДиск",КонфигурацияСетевойДиск);
	
	ЗаписьJSON = Новый ПарсерJSON() ;
	СтрокаJSON = ЗаписьJSON.ЗаписатьJSON(Конфигурация);
	Сообщить(СтрокаJSON);
	Текст = Новый ТекстовыйДокумент() ;
	Текст.ДобавитьСтроку(СтрокаJSON);
	Текст.Записать(ИмяФайлаКонфигурации);

КонецПроцедуры

Процедура Выполнение()
Если АргументыКоманднойСтроки.Количество()=0 Тогда 
	Сообщить("Нужно  добавить параметры ") ;
	Возврат ;

ИначеЕсли АргументыКоманднойСтроки.Количество()> 0 Тогда
	СтрПараметр = АргументыКоманднойСтроки[0] ;
	Если СтрПараметр ="genjson" Тогда // создание примера файла конфигурации 
		// - Имя файла уонфигурации -- c:\temp\conf.json
		СоздатьФайлКонфигурации(АргументыКоманднойСтроки[1]) ;
	
	ИначеЕсли СтрПараметр ="genkey" Тогда // подоговка ключа  
		// - Имя файла уонфигурации -- c:\temp\conf.json
		// - Имя файла ключа -- c:\temp\conf.key
		КодированиеРесурса(АргументыКоманднойСтроки[1],АргументыКоманднойСтроки[2]);	
	
	ИначеЕсли СтрПараметр ="work" Тогда // выполнение 

		// - Имя файла ключа -- c:\temp\conf.key
		Конфигурация = ПрочитатьКонфигурацию(АргументыКоманднойСтроки[1]); 
		ОбработатьФайлы(Конфигурация) ;	
	
	КонецЕсли ;

КонецЕсли ;

КонецПроцедуры
////////////////////////
Выполнение();
