import XCTest
import GOST56042

final class GOST56042StringTests: XCTestCase {
    let parser = Parser()

    let header = "ST00012|"

    let requiredFields = "Name=ООО \"АйТи Компания\"|PersonalAcc=12345678901234567890|BankName=ОТДЕЛЕНИЕ №1234 ПАО БАНК|BIC=012345678|CorrespAcc=30101810400000000601|"

    var goodDataInUtf8: String {
        return header + requiredFields
    }

    func testEmptyStringReturnNil() {
        // Given
        let stringData = ""

        // When
        let gost = parser.parse(with: stringData)

        // Then
        XCTAssertNil(gost)
    }

    func testWrongFormatReturnNil() {
        // Given
        let format = "SA"
        let stringData = format + "00012|" + requiredFields

        // When
        let gost = parser.parse(with: stringData)

        // Then
        XCTAssertNil(gost)
    }

    func testWrongVersionReturnNil() {
        // Given
        let version = "0002"
        let stringData = "ST" + version + "2|" + requiredFields

        // When
        let gost = parser.parse(with: stringData)

        // Then
        XCTAssertNil(gost)
    }

    func testWrongEncoding0ReturnNil() {
        // Given
        let encoding = "0"
        let stringData = "ST0001" + encoding + "|" + requiredFields

        // When
        let gost = parser.parse(with: stringData, parseMode: .loose)

        // Then
        XCTAssertNil(gost)
    }

    func testWrongEncoding4ReturnNil() {
        // Given
        let encoding = "4"
        let stringData = "ST0001" + encoding + "|" + requiredFields

        // When
        let gost = parser.parse(with: stringData, parseMode: .loose)

        // Then
        XCTAssertNil(gost)
    }

    func testRightEncoding1ReturnNonNil() {
        // Given
        let encoding = "1"
        let stringData = "ST0001" + encoding + "|" + requiredFields

        // When
        let gost = parser.parse(with: stringData, parseMode: .loose)

        // Then
        XCTAssertNotNil(gost)
    }

    func testRightEncoding2ReturnNonNil() {
        // Given
        let encoding = "2"
        let stringData = "ST0001" + encoding + "|" + requiredFields

        // When
        let gost = parser.parse(with: stringData, parseMode: .loose)

        // Then
        XCTAssertNotNil(gost)
    }

    func testRightEncoding3ReturnNonNil() {
        // Given
        let encoding = "3"
        let stringData = "ST0001" + encoding + "|" + requiredFields

        // When
        let gost = parser.parse(with: stringData, parseMode: .loose)

        // Then
        XCTAssertNotNil(gost)
    }

    func testUtf8DataNotNil() {
        // Given
        let stringData = goodDataInUtf8

        // When
        let gost = parser.parse(with: stringData)

        // Then
        XCTAssertNotNil(gost)
    }

    func testWin1251DataNotNil() {
        // Given
        let fileUrl = Bundle.module.url(forResource: "win1251", withExtension: "txt")!
        let win1251Data = try? Data(contentsOf: fileUrl)
        XCTAssertNotNil(win1251Data)
        let stringData = String(data: win1251Data!, encoding: .windowsCP1251)
        XCTAssertNotNil(stringData)

        // When
        let gost = parser.parse(with: stringData!)

        // Then
        XCTAssertNotNil(gost)
    }

    // MARK: - Fields

    func testReqiuredFields () {
        // Given
        let stringData = header + requiredFields

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertEqual(gost[.Name], "ООО \"АйТи Компания\"")
        XCTAssertEqual(gost[.PersonalAcc], "12345678901234567890")
        XCTAssertEqual(gost[.BankName], "ОТДЕЛЕНИЕ №1234 ПАО БАНК")
        XCTAssertEqual(gost[.BIC], "012345678")
        XCTAssertEqual(gost[.CorrespAcc], "30101810400000000601")
    }

    func testEndsWithSeparatorReturnNotNil() {
        // Given
        let stringData = goodDataInUtf8 + "|"

        // When
        let gost = parser.parse(with: stringData)

        // Then
        XCTAssertNotNil(gost)
    }

    func testAdditionalFields () {
        // Given
        let additionalFields =  [
               "Sum=456789",
               "Purpose=За услуги",
               "PayeeINN=564567867444",
               "PayerINN=7713457897",
               "DrawerStatus=15",
               "KPP=111222333",
               "CBC=18811302031010000130",
               "OKTMO=45268554000",
               "PaytReason=ТП",
               "TaxPeriod=МС.03.2003",
               "DocNo=645645645",
               "DocDate=20.08.2013",
               "TaxPaytKind=НС",
               ].joined(separator: "|")
        let stringData = header + requiredFields + additionalFields

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertEqual(gost[.Sum], "456789")
        XCTAssertEqual(gost[.Purpose], "За услуги")
        XCTAssertEqual(gost[.PayeeINN], "564567867444")
        XCTAssertEqual(gost[.PayerINN], "7713457897")
        XCTAssertEqual(gost[.DrawerStatus], "15")
        XCTAssertEqual(gost[.KPP], "111222333")
        XCTAssertEqual(gost[.CBC], "18811302031010000130")
        XCTAssertEqual(gost[.OKTMO], "45268554000")
        XCTAssertEqual(gost[.PaytReason], "ТП")
        XCTAssertEqual(gost[.TaxPeriod], "МС.03.2003")
        XCTAssertEqual(gost[.DocNo], "645645645")
        XCTAssertEqual(gost[.DocDate], "20.08.2013")
        XCTAssertEqual(gost[.TaxPaytKind], "НС")
    }

    func testOtherFields() {
        // Given
        let otherFields =  [
               "LastName=Иванов",
               "FirstName=Иван",
               "MiddleName=Иванович",
               "PayerAddress=г.Рязань ул.Ленина д.10 кв.15",
               "PersonalAccount=343-34-34",
               "DocIdx=343",
               "PensAccNo=116-973-385 89",
               "Contract=109-09-23",
               "PersAcc=40101810500000010001",
               "Flat=15",
               "Phone=79101234567",
               "PayerIdType=44",
               "PayerIdNum=4666.1126",
               "ChildFio=Приглядов Антов Русланович",
               "BirthDate=30.12.1987",
               "PaymTerm=29.02.2020",
               "PaymPeriod=62015",
               "Category=01",
               "ServiceName=40",
               "CounterId=11",
               "CounterVal=678",
               "QuittId=9839-93-03",
               "QuittDate=01.01.2020",
               "InstNum=343-ND",
               "ClassNum=5А",
               "SpecFio=Зарецкий Марк Валентинович",
               "AddAmount=14155",
               "RuleId=18810177170124069863",
               "ExecId=12-12-12",
               "RegType=1010",
               "UIN=18203702140083959124",
               "TechCode=5",
               ].joined(separator: "|")

        let stringData = header + requiredFields + otherFields

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertEqual(gost[.LastName], "Иванов")
        XCTAssertEqual(gost[.FirstName], "Иван")
        XCTAssertEqual(gost[.MiddleName], "Иванович")
        XCTAssertEqual(gost[.PayerAddress], "г.Рязань ул.Ленина д.10 кв.15")
        XCTAssertEqual(gost[.PersonalAccount], "343-34-34")
        XCTAssertEqual(gost[.DocIdx], "343")
        XCTAssertEqual(gost[.PensAccNo], "116-973-385 89")
        XCTAssertEqual(gost[.Contract], "109-09-23")
        XCTAssertEqual(gost[.PersAcc], "40101810500000010001")
        XCTAssertEqual(gost[.Flat], "15")
        XCTAssertEqual(gost[.Phone], "79101234567")
        XCTAssertEqual(gost[.PayerIdType], "44")
        XCTAssertEqual(gost[.PayerIdNum], "4666.1126")
        XCTAssertEqual(gost[.ChildFio], "Приглядов Антов Русланович")
        XCTAssertEqual(gost[.BirthDate], "30.12.1987")
        XCTAssertEqual(gost[.PaymTerm], "29.02.2020")
        XCTAssertEqual(gost[.PaymPeriod], "62015")
        XCTAssertEqual(gost[.Category], "01")
        XCTAssertEqual(gost[.ServiceName], "40")
        XCTAssertEqual(gost[.CounterId], "11")
        XCTAssertEqual(gost[.CounterVal], "678")
        XCTAssertEqual(gost[.QuittId], "9839-93-03")
        XCTAssertEqual(gost[.QuittDate], "01.01.2020")
        XCTAssertEqual(gost[.InstNum], "343-ND")
        XCTAssertEqual(gost[.ClassNum], "5А")
        XCTAssertEqual(gost[.SpecFio], "Зарецкий Марк Валентинович")
        XCTAssertEqual(gost[.AddAmount], "14155")
        XCTAssertEqual(gost[.RuleId], "18810177170124069863")
        XCTAssertEqual(gost[.ExecId], "12-12-12")
        XCTAssertEqual(gost[.RegType], "1010")
        XCTAssertEqual(gost[.UIN], "18203702140083959124")
        XCTAssertEqual(gost[.TechCode], "5")
    }

    func testCaseInsensitiveSubscriptFieldKeysNotNil() {
        // Given
        let mixCasedGoodData = "ST00012|nAmE=ООО \"Ромашка\"|peRSonALacC=12345678901234567890|BANKNAME=ОТДЕЛЕНИЕ N1234 ПАО БАНК|BIC=012345678|correspacc=30101810400000000601|PAYEEinn=1234567890|lastName=Иванов И.И|payerAddress=пр. Ленина, дом 1|Purpose=За лучшие услуги|sUM=456789"


        // When
        let gost = parser.parse(with: mixCasedGoodData)!

        // Then
        XCTAssertNotNil(gost[.Name])
        XCTAssertNotNil(gost[.PersonalAcc])
        XCTAssertNotNil(gost[.PayeeINN])
        XCTAssertNotNil(gost[.BankName])
        XCTAssertNotNil(gost[.BIC])
        XCTAssertNotNil(gost[.CorrespAcc])
        XCTAssertNotNil(gost[.Sum])
    }


    func testCustomFields() {
        // Given
        let customFields =  [
               "KaznPersonalAcc=85630016000",
               "calc=412133",
               "debt=315483",
               "penaltyfee=116",
               "insurance=10060",
               ].joined(separator: "|")

        let stringData = header + requiredFields + customFields

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertEqual(gost["KaznPersonalAcc"], "85630016000")
        XCTAssertEqual(gost["calc"], "412133")
        XCTAssertEqual(gost["debt"], "315483")
        XCTAssertEqual(gost["penaltyfee"], "116")
        XCTAssertEqual(gost["insurance"], "10060")
    }

    func testCaseInsensitiveSubscriptCustomKeysNotNil() {
        // Given
        let customFields =  [
               "KaznPersonalAcc=85630016000",
               "calc=412133",
               "debt=315483",
               "penaltyfee=116",
               "insurance=10060",
               ].joined(separator: "|")
        let stringData = header + requiredFields + customFields

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNotNil(gost["nAME"])
        XCTAssertNotNil(gost["KaznPersonalAcc"])
        XCTAssertNotNil(gost["CALC"])
        XCTAssertNotNil(gost["dEbT"])
        XCTAssertNotNil(gost["pEnAltyFEE"])
        XCTAssertNotNil(gost["INSUrance"])
    }

    func testLooseParseModeReturnNonNil() {
        // Given
        let stringData = "ST00012|Name=ООО \"Ромашка\""

        // When
        let gost = parser.parse(with: stringData, parseMode: .loose)

        // Then
        XCTAssertNotNil(gost)
    }

    func testLooseParseModeWithOnlyHeaderReturnNil() {
        // Given
        let stringData = header

        // When
        let gost = parser.parse(with: stringData, parseMode: .loose)

        // Then
        XCTAssertNil(gost)
    }

    func testEmptyFieldReturnNil() {
        // Given
        let stringData = goodDataInUtf8 + "|Field="

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNil(gost["Field"])
    }

    func testEmptyStringValueFieldReturnNil() {
        // Given
        let stringData = goodDataInUtf8 + "|Field= |Other=1234"

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNil(gost["Field"])
    }

    func testNewLineValueFieldReturnNil() {
        // Given
        let stringData = goodDataInUtf8 + "|Field=\n|Other=1234"

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNil(gost["Field"])
    }

    func testEmptyStringKeyFieldReturnNil() {
        // Given
        let stringData = goodDataInUtf8 + "| =1234|Other=1234"

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNil(gost[" "])
    }

    func testNewLineKeyFieldReturnNil() {
        // Given
        let stringData = goodDataInUtf8 + "|\n=1234|Other=1234"

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNil(gost["\n"])
    }

    func testFieldWithOnlyEqualsReturnNil() {
        // Given
        let stringData = goodDataInUtf8 + "|="

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNil(gost[""])
        XCTAssertNil(gost["="])
    }

    func testFieldWithoutEqualsReturnNil() {
        // Given
        let stringData = goodDataInUtf8 + "|asdf"

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNil(gost["asdf"])
        XCTAssertNil(gost[""])

    }

    func testFieldWithOnlyValueReturnNil() {
        // Given
        let stringData = goodDataInUtf8 + "=aa"

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNil(gost[""])
        XCTAssertNil(gost["aa"])
    }

    func testNullFieldReturnNil() {
        // Given
        let stringData = goodDataInUtf8 + "|Field=Null"

        // When
        let gost = parser.parse(with: stringData)!

        // Then
        XCTAssertNil(gost["Field"])
    }
}
