import XCTest
import GOST56042

final class GOST56042DataTests: XCTestCase {

    let parser = Parser()

    // "ST00012|"
    let header: [UInt8] = [83, 84, 48, 48, 48, 49, 50, 124]

    //"Name=ООО \"АйТи Компания\"|PersonalAcc=12345678901234567890|BankName=ОТДЕЛЕНИЕ N1234 ПАО БАНК|BIC=012345678|CorrespAcc=30101810400000000601|"
    let requiredFields: [UInt8] = [78, 97, 109, 101, 61, 208, 158, 208, 158, 208, 158, 32, 34, 208, 144, 208, 185, 208, 162, 208, 184, 32, 208, 154, 208, 190, 208, 188, 208, 191, 208, 176, 208, 189, 208, 184, 209, 143, 34, 124, 80, 101, 114, 115, 111, 110, 97, 108, 65, 99, 99, 61, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 124, 66, 97, 110, 107, 78, 97, 109, 101, 61, 208, 158, 208, 162, 208, 148, 208, 149, 208, 155, 208, 149, 208, 157, 208, 152, 208, 149, 32, 78, 49, 50, 51, 52, 32, 208, 159, 208, 144, 208, 158, 32, 208, 145, 208, 144, 208, 157, 208, 154, 124, 66, 73, 67, 61, 48, 49, 50, 51, 52, 53, 54, 55, 56, 124, 67, 111, 114, 114, 101, 115, 112, 65, 99, 99, 61, 51, 48, 49, 48, 49, 56, 49, 48, 52, 48, 48, 48, 48, 48, 48, 48, 48, 54, 48, 49, 124]


    var goodDataInUtf8: [UInt8] {
        return header + requiredFields
    }

    func testEmptyDataReturnNil() {
        // Given
        let data = Data()

        // When
        let gost = parser.parse(with: data)

        // Then
        XCTAssertNil(gost)
    }

    func testWrongFormatReturnNil() {
        // Given
        // SA00012|
        let header: [UInt8] = [83, 65, 48, 48, 48, 49, 50, 124]
        let data = Data(header + requiredFields)

        // When
        let gost = parser.parse(with: data)

        // Then
        XCTAssertNil(gost)
    }

    func testWrongVersionReturnNil() {
        // Given
        // ST00022|
        let header: [UInt8] = [83, 84, 48, 48, 48, 50, 50, 124]
        let data = Data(header + requiredFields)

        // When
        let gost = parser.parse(with: data)

        // Then
        XCTAssertNil(gost)
    }

    func testWrongEncoding0ReturnNil() {
        // Given
        // ST00010|
        let header: [UInt8] = [83, 84, 48, 48, 48, 49, 48, 124]
        let data = Data(header + requiredFields)

        // When
        let gost = parser.parse(with: data, parseMode: .loose)

        // Then
        XCTAssertNil(gost)
    }

    func testWrongEncoding4ReturnNil() {
        // Given
        // ST00014|
        let header: [UInt8] = [83, 84, 48, 48, 48, 49, 52, 124]
        let data = Data(header + requiredFields)

        // When
        let gost = parser.parse(with: data, parseMode: .loose)

        // Then
        XCTAssertNil(gost)
    }

    func testRightEncoding1ReturnNonNil() {
        // Given
        // ST00011|
        let header: [UInt8] = [83, 84, 48, 48, 48, 49, 49, 124]
        let data = Data(header + requiredFields)

        // When
        let gost = parser.parse(with: data, parseMode: .loose)

        // Then
        XCTAssertNotNil(gost)
    }

    func testRightEncoding2ReturnNonNil() {
        // Given
        // ST00012|
        let header: [UInt8] = [83, 84, 48, 48, 48, 49, 50, 124]
        let data = Data(header + requiredFields)

        // When
        let gost = parser.parse(with: data, parseMode: .loose)

        // Then
        XCTAssertNotNil(gost)
    }

    func testRightEncoding3ReturnNonNil() {
        // Given
        // ST00013|
        let header: [UInt8] = [83, 84, 48, 48, 48, 49, 51, 124]
        let data = Data(header + requiredFields)

        // When
        let gost = parser.parse(with: data, parseMode: .loose)

        // Then
        XCTAssertNotNil(gost)
    }

    func testUtf8DataNotNil() {
        // Given
        let data = Data(goodDataInUtf8)

        // When
        let gost = parser.parse(with: data)

        // Then
        XCTAssertNotNil(gost)
    }

    func testWin1251DataNotNil() {
        // Given
        let fileUrl = Bundle.module.url(forResource: "win1251", withExtension: "txt")!
        let win1251Data = try? Data(contentsOf: fileUrl)
        XCTAssertNotNil(win1251Data)

        // When
        let gost = parser.parse(with: win1251Data!)

        // Then
        XCTAssertNotNil(gost)
    }

    // MARK: - Fields

    func testReqiuredFields () {
        // Given
        let data = Data(header + requiredFields)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertEqual(gost[.Name], "ООО \"АйТи Компания\"")
        XCTAssertEqual(gost[.PersonalAcc], "12345678901234567890")
        XCTAssertEqual(gost[.BankName], "ОТДЕЛЕНИЕ N1234 ПАО БАНК")
        XCTAssertEqual(gost[.BIC], "012345678")
        XCTAssertEqual(gost[.CorrespAcc], "30101810400000000601")
    }

    func testEndsWithoutLastSeparatorReturnNotNil() {
        // Given
        let withoutLastSeparator = goodDataInUtf8.dropLast()
        let data = Data(withoutLastSeparator)

        // When
        let gost = parser.parse(with: data)

        // Then
        XCTAssertNotNil(gost)
    }

    func testAdditionalFields () {
        // Given
        // Sum=456789|Purpose=За услуги|PayeeINN=564567867444|PayerINN=7713457897|DrawerStatus=15|KPP=111222333|CBC=18811302031010000130|OKTMO=45268554000|PaytReason=ТП|TaxPeriod=МС.03.2003|DocNo=645645645|DocDate=20.08.2013|TaxPaytKind=НС
        let additionalFields: [UInt8] =  [83, 117, 109, 61, 52, 53, 54, 55, 56, 57, 124, 80, 117, 114, 112, 111, 115, 101, 61, 208, 151, 208, 176, 32, 209, 131, 209, 129, 208, 187, 209, 131, 208, 179, 208, 184, 124, 80, 97, 121, 101, 101, 73, 78, 78, 61, 53, 54, 52, 53, 54, 55, 56, 54, 55, 52, 52, 52, 124, 80, 97, 121, 101, 114, 73, 78, 78, 61, 55, 55, 49, 51, 52, 53, 55, 56, 57, 55, 124, 68, 114, 97, 119, 101, 114, 83, 116, 97, 116, 117, 115, 61, 49, 53, 124, 75, 80, 80, 61, 49, 49, 49, 50, 50, 50, 51, 51, 51, 124, 67, 66, 67, 61, 49, 56, 56, 49, 49, 51, 48, 50, 48, 51, 49, 48, 49, 48, 48, 48, 48, 49, 51, 48, 124, 79, 75, 84, 77, 79, 61, 52, 53, 50, 54, 56, 53, 53, 52, 48, 48, 48, 124, 80, 97, 121, 116, 82, 101, 97, 115, 111, 110, 61, 208, 162, 208, 159, 124, 84, 97, 120, 80, 101, 114, 105, 111, 100, 61, 208, 156, 208, 161, 46, 48, 51, 46, 50, 48, 48, 51, 124, 68, 111, 99, 78, 111, 61, 54, 52, 53, 54, 52, 53, 54, 52, 53, 124, 68, 111, 99, 68, 97, 116, 101, 61, 50, 48, 46, 48, 56, 46, 50, 48, 49, 51, 124, 84, 97, 120, 80, 97, 121, 116, 75, 105, 110, 100, 61, 208, 157, 208, 161]
        let data = Data(header + requiredFields + additionalFields)

        // When
        let gost = parser.parse(with: data)!
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
        // LastName=Иванов|FirstName=Иван|MiddleName=Иванович|PayerAddress=г.Рязань ул.Ленина д.10 кв.15|PersonalAccount=343-34-34|DocIdx=343|PensAccNo=116-973-385 89|Contract=109-09-23|PersAcc=40101810500000010001|Flat=15|Phone=79101234567|PayerIdType=44|PayerIdNum=4666.1126|ChildFio=Приглядов Антов Русланович|BirthDate=30.12.1987|PaymTerm=29.02.2020|PaymPeriod=62015|Category=01|ServiceName=40|CounterId=11|CounterVal=678|QuittId=9839-93-03|QuittDate=01.01.2020|InstNum=343-ND|ClassNum=5А|SpecFio=Зарецкий Марк Валентинович|AddAmount=14155|RuleId=18810177170124069863|ExecId=12-12-12|RegType=1010|UIN=18203702140083959124|TechCode=5
        let otherFields: [UInt8] = [76, 97, 115, 116, 78, 97, 109, 101, 61, 208, 152, 208, 178, 208, 176, 208, 189, 208, 190, 208, 178, 124, 70, 105, 114, 115, 116, 78, 97, 109, 101, 61, 208, 152, 208, 178, 208, 176, 208, 189, 124, 77, 105, 100, 100, 108, 101, 78, 97, 109, 101, 61, 208, 152, 208, 178, 208, 176, 208, 189, 208, 190, 208, 178, 208, 184, 209, 135, 124, 80, 97, 121, 101, 114, 65, 100, 100, 114, 101, 115, 115, 61, 208, 179, 46, 208, 160, 209, 143, 208, 183, 208, 176, 208, 189, 209, 140, 32, 209, 131, 208, 187, 46, 208, 155, 208, 181, 208, 189, 208, 184, 208, 189, 208, 176, 32, 208, 180, 46, 49, 48, 32, 208, 186, 208, 178, 46, 49, 53, 124, 80, 101, 114, 115, 111, 110, 97, 108, 65, 99, 99, 111, 117, 110, 116, 61, 51, 52, 51, 45, 51, 52, 45, 51, 52, 124, 68, 111, 99, 73, 100, 120, 61, 51, 52, 51, 124, 80, 101, 110, 115, 65, 99, 99, 78, 111, 61, 49, 49, 54, 45, 57, 55, 51, 45, 51, 56, 53, 32, 56, 57, 124, 67, 111, 110, 116, 114, 97, 99, 116, 61, 49, 48, 57, 45, 48, 57, 45, 50, 51, 124, 80, 101, 114, 115, 65, 99, 99, 61, 52, 48, 49, 48, 49, 56, 49, 48, 53, 48, 48, 48, 48, 48, 48, 49, 48, 48, 48, 49, 124, 70, 108, 97, 116, 61, 49, 53, 124, 80, 104, 111, 110, 101, 61, 55, 57, 49, 48, 49, 50, 51, 52, 53, 54, 55, 124, 80, 97, 121, 101, 114, 73, 100, 84, 121, 112, 101, 61, 52, 52, 124, 80, 97, 121, 101, 114, 73, 100, 78, 117, 109, 61, 52, 54, 54, 54, 46, 49, 49, 50, 54, 124, 67, 104, 105, 108, 100, 70, 105, 111, 61, 208, 159, 209, 128, 208, 184, 208, 179, 208, 187, 209, 143, 208, 180, 208, 190, 208, 178, 32, 208, 144, 208, 189, 209, 130, 208, 190, 208, 178, 32, 208, 160, 209, 131, 209, 129, 208, 187, 208, 176, 208, 189, 208, 190, 208, 178, 208, 184, 209, 135, 124, 66, 105, 114, 116, 104, 68, 97, 116, 101, 61, 51, 48, 46, 49, 50, 46, 49, 57, 56, 55, 124, 80, 97, 121, 109, 84, 101, 114, 109, 61, 50, 57, 46, 48, 50, 46, 50, 48, 50, 48, 124, 80, 97, 121, 109, 80, 101, 114, 105, 111, 100, 61, 54, 50, 48, 49, 53, 124, 67, 97, 116, 101, 103, 111, 114, 121, 61, 48, 49, 124, 83, 101, 114, 118, 105, 99, 101, 78, 97, 109, 101, 61, 52, 48, 124, 67, 111, 117, 110, 116, 101, 114, 73, 100, 61, 49, 49, 124, 67, 111, 117, 110, 116, 101, 114, 86, 97, 108, 61, 54, 55, 56, 124, 81, 117, 105, 116, 116, 73, 100, 61, 57, 56, 51, 57, 45, 57, 51, 45, 48, 51, 124, 81, 117, 105, 116, 116, 68, 97, 116, 101, 61, 48, 49, 46, 48, 49, 46, 50, 48, 50, 48, 124, 73, 110, 115, 116, 78, 117, 109, 61, 51, 52, 51, 45, 78, 68, 124, 67, 108, 97, 115, 115, 78, 117, 109, 61, 53, 208, 144, 124, 83, 112, 101, 99, 70, 105, 111, 61, 208, 151, 208, 176, 209, 128, 208, 181, 209, 134, 208, 186, 208, 184, 208, 185, 32, 208, 156, 208, 176, 209, 128, 208, 186, 32, 208, 146, 208, 176, 208, 187, 208, 181, 208, 189, 209, 130, 208, 184, 208, 189, 208, 190, 208, 178, 208, 184, 209, 135, 124, 65, 100, 100, 65, 109, 111, 117, 110, 116, 61, 49, 52, 49, 53, 53, 124, 82, 117, 108, 101, 73, 100, 61, 49, 56, 56, 49, 48, 49, 55, 55, 49, 55, 48, 49, 50, 52, 48, 54, 57, 56, 54, 51, 124, 69, 120, 101, 99, 73, 100, 61, 49, 50, 45, 49, 50, 45, 49, 50, 124, 82, 101, 103, 84, 121, 112, 101, 61, 49, 48, 49, 48, 124, 85, 73, 78, 61, 49, 56, 50, 48, 51, 55, 48, 50, 49, 52, 48, 48, 56, 51, 57, 53, 57, 49, 50, 52, 124, 84, 101, 99, 104, 67, 111, 100, 101, 61, 53]
        let data = Data(header + requiredFields + otherFields)

        // When
        let gost = parser.parse(with: data)!

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
        // nAmE=ООО \"Ромашка\"|peRSonALacC=12345678901234567890|BANKNAME=ОТДЕЛЕНИЕ N1234 ПАО БАНК|BIC=012345678|correspacc=30101810400000000601|PAYEEinn=1234567890|lastName=Иванов И.И|payerAddress=пр. Ленина, дом 1|Purpose=За лучшие услуги|sUM=456789
        let mixCasedGoodData: [UInt8] = [110, 65, 109, 69, 61, 208, 158, 208, 158, 208, 158, 32, 34, 208, 160, 208, 190, 208, 188, 208, 176, 209, 136, 208, 186, 208, 176, 34, 124, 112, 101, 82, 83, 111, 110, 65, 76, 97, 99, 67, 61, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 124, 66, 65, 78, 75, 78, 65, 77, 69, 61, 208, 158, 208, 162, 208, 148, 208, 149, 208, 155, 208, 149, 208, 157, 208, 152, 208, 149, 32, 78, 49, 50, 51, 52, 32, 208, 159, 208, 144, 208, 158, 32, 208, 145, 208, 144, 208, 157, 208, 154, 124, 66, 73, 67, 61, 48, 49, 50, 51, 52, 53, 54, 55, 56, 124, 99, 111, 114, 114, 101, 115, 112, 97, 99, 99, 61, 51, 48, 49, 48, 49, 56, 49, 48, 52, 48, 48, 48, 48, 48, 48, 48, 48, 54, 48, 49, 124, 80, 65, 89, 69, 69, 105, 110, 110, 61, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 124, 108, 97, 115, 116, 78, 97, 109, 101, 61, 208, 152, 208, 178, 208, 176, 208, 189, 208, 190, 208, 178, 32, 208, 152, 46, 208, 152, 124, 112, 97, 121, 101, 114, 65, 100, 100, 114, 101, 115, 115, 61, 208, 191, 209, 128, 46, 32, 208, 155, 208, 181, 208, 189, 208, 184, 208, 189, 208, 176, 44, 32, 208, 180, 208, 190, 208, 188, 32, 49, 124, 80, 117, 114, 112, 111, 115, 101, 61, 208, 151, 208, 176, 32, 208, 187, 209, 131, 209, 135, 209, 136, 208, 184, 208, 181, 32, 209, 131, 209, 129, 208, 187, 209, 131, 208, 179, 208, 184, 124, 115, 85, 77, 61, 52, 53, 54, 55, 56, 57]
        let data = Data(header + mixCasedGoodData)

        // When
        let gost = parser.parse(with: data)!
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
        // KaznPersonalAcc=85630016000|calc=412133|debt=315483|penaltyfee=116|insurance=10060
        let customFields: [UInt8] =  [75, 97, 122, 110, 80, 101, 114, 115, 111, 110, 97, 108, 65, 99, 99, 61, 56, 53, 54, 51, 48, 48, 49, 54, 48, 48, 48, 124, 99, 97, 108, 99, 61, 52, 49, 50, 49, 51, 51, 124, 100, 101, 98, 116, 61, 51, 49, 53, 52, 56, 51, 124, 112, 101, 110, 97, 108, 116, 121, 102, 101, 101, 61, 49, 49, 54, 124, 105, 110, 115, 117, 114, 97, 110, 99, 101, 61, 49, 48, 48, 54, 48]
        let data = Data(header + requiredFields + customFields)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertEqual(gost["KaznPersonalAcc"], "85630016000")
        XCTAssertEqual(gost["calc"], "412133")
        XCTAssertEqual(gost["debt"], "315483")
        XCTAssertEqual(gost["penaltyfee"], "116")
        XCTAssertEqual(gost["insurance"], "10060")
    }

    func testCaseInsensitiveSubscriptCustomKeysNotNil() {
        // Given
        // KaznPersonalAcc=85630016000|calc=412133|debt=315483|penaltyfee=116|insurance=10060
        let customFields: [UInt8] =  [75, 97, 122, 110, 80, 101, 114, 115, 111, 110, 97, 108, 65, 99, 99, 61, 56, 53, 54, 51, 48, 48, 49, 54, 48, 48, 48, 124, 99, 97, 108, 99, 61, 52, 49, 50, 49, 51, 51, 124, 100, 101, 98, 116, 61, 51, 49, 53, 52, 56, 51, 124, 112, 101, 110, 97, 108, 116, 121, 102, 101, 101, 61, 49, 49, 54, 124, 105, 110, 115, 117, 114, 97, 110, 99, 101, 61, 49, 48, 48, 54, 48]
        let data = Data(header + requiredFields + customFields)

        // When
        let gost = parser.parse(with: data)!

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
        // ST00012|Name=ООО \"Ромашка\"
        let name: [UInt8] = [78, 97, 109, 101, 61, 208, 158, 208, 158, 208, 158, 32, 34, 208, 160, 208, 190, 208, 188, 208, 176, 209, 136, 208, 186, 208, 176, 34]
        let data = Data(header + name)

        // When
        let gost = parser.parse(with: data, parseMode: .loose)

        // Then
        XCTAssertNotNil(gost)
    }

    func testLooseParseModeWithOnlyHeaderReturnNil() {
        // Given
        let data = Data(header)

        // When
        let gost = parser.parse(with: data, parseMode: .loose)

        // Then
        XCTAssertNil(gost)
    }

    func testEmptyFieldReturnNil() {
        // Given
        // Field=
        let other: [UInt8] = [70, 105, 101, 108, 100, 61]
        let data = Data(header + requiredFields + other)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertNil(gost["Field"])
    }

    func testEmptyStringValueFieldReturnNil() {
        // Given
        // Field= |Other=1234
        let other: [UInt8] = [70, 105, 101, 108, 100, 61, 32, 124, 79, 116, 104, 101, 114, 61, 49, 50, 51, 52]
        let data = Data(header + requiredFields + other)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertNil(gost["Field"])
    }

    func testNewLineValueFieldReturnNil() {
        // Given
        // Field=\n|Other=1234
        let other: [UInt8] = [70, 105, 101, 108, 100, 61, 10, 124, 79, 116, 104, 101, 114, 61, 49, 50, 51, 52]
        let data = Data(header + requiredFields + other)

        // When
        let gost = parser.parse(with: data)!


        // Then
        XCTAssertNil(gost["Field"])
    }

    func testEmptyStringKeyFieldReturnNil() {
        // Given
        //  =1234|Other=1234
        let other: [UInt8] = [32, 61, 49, 50, 51, 52, 124, 79, 116, 104, 101, 114, 61, 49, 50, 51, 52]
        let data = Data(header + requiredFields + other)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertNil(gost[" "])
    }

    func testNewLineKeyFieldReturnNil() {
        // Given
        // \n=1234|Other=1234
        let other: [UInt8] = [10, 61, 49, 50, 51, 52, 124, 79, 116, 104, 101, 114, 61, 49, 50, 51, 52]
        let data = Data(header + requiredFields + other)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertNil(gost["\n"])
    }

    func testFieldWithOnlyEqualsReturnNil() {
        // Given
        // =
        let other: [UInt8] = [61]
        let data = Data(header + requiredFields + other)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertNil(gost[""])
        XCTAssertNil(gost["="])
    }

    func testFieldWithoutEqualsReturnNil() {
        // Given
        // asdf
        let other: [UInt8] = [97, 115, 100, 102]
        let data = Data(header + requiredFields + other)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertNil(gost["asdf"])
        XCTAssertNil(gost[""])

    }

    func testFieldWithOnlyValueReturnNil() {
        // Given
        // =aa
        let other: [UInt8] = [61, 97, 97]
        let data = Data(header + requiredFields + other)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertNil(gost[""])
        XCTAssertNil(gost["aa"])
    }

    func testNullFieldReturnNil() {
        // Given
        // Field=Null
        let other: [UInt8] = [70, 105, 101, 108, 100, 61, 78, 117, 108, 108]
        let data = Data(header + requiredFields + other)

        // When
        let gost = parser.parse(with: data)!

        // Then
        XCTAssertNil(gost["Field"])
    }
}
