import Foundation

public enum PaymentField: String, CaseIterable {
    // MARK: - Required
    // Обязательные реквизиты

    /// Наименование получателя платежа
    case Name

    /// Номер счета получателя платежа
    case PersonalAcc

    /// Наименование банка получателя платежа
    case BankName

    /// БИК
    case BIC

    /// Номер кор./сч. банка получателя платежа
    case CorrespAcc

    // MARK: - Additional
    // Дополнительные реквизиты

    /// Сумма платежа, в копейках
    case Sum

    /// Наименование платежа (назначение)
    case Purpose

    /// ИНН получателя платежа
    case PayeeINN

    /// ИНН плательщика
    case PayerINN

    /// Статус составителя платежного документа
    case DrawerStatus

    /// КПП получателя платежа
    case KPP

    /// КБК
    case CBC

    /// Общероссийский классификатор территорий муниципальных образований(ОКТМО)
    case OKTMO

    /// Основание налогового платежа
    case PaytReason

    /// Налоговый период
    case TaxPeriod

    /// Номер документа
    case DocNo

    /// Дата документа
    case DocDate

    /// Тип платежа
    case TaxPaytKind

    // MARK: - Other additional
    // Прочие дополнительные реквизиты

    /// Фамилия плательщика
    case LastName

    /// Имя плательщика
    case FirstName

    /// Отчество плательщика
    case MiddleName

    /// Адрес плательщика
    case PayerAddress

    /// Лицевой счет бюджетного получателя
    case PersonalAccount

    /// Индекс платежного документа
    case DocIdx

    ///  Номер лицевого счета в системе персонифицированного учета в ПФР-СНИЛС
    case PensAccNo

    /// Номер договора
    case Contract

    /// Номер лицевого счета плательщика в организации (в системе учета ПУ)
    case PersAcc

    /// Номер квартиры
    case Flat

    /// Номер телефона
    case Phone

    /// Вид ДУЛ плательщика
    case PayerIdType

    /// Номер ДУЛ плательщика
    case PayerIdNum

    /// Ф.И.О. ребенка/учащегося
    case ChildFio

    /// Дата рождения
    case BirthDate

    /// Срок платежа/дата выставления счета
    case PaymTerm

    /// Период оплаты
    case PaymPeriod

    /// Вид платежа
    case Category

    /// Код услуги/название прибора учета
    case ServiceName

    /// Номер прибора учета
    case CounterId

    /// Показание прибора учета
    case CounterVal

    /// Номер извещения, начисления, счета
    case QuittId

    /// Дата извещения/начисления/счета/постановления (для ГИБДД)
    case QuittDate

    /// Номер учреждения (образовательного, медицинского)
    case InstNum

    /// Номер группы детсада/класса школы
    case ClassNum

    /// ФИО преподавателя, специалиста, оказывающего услугу
    case SpecFio

    /// Сумма страховки/дополнительной услуги/Сумма пени (в копейках)
    case AddAmount

    /// Номер постановления(для ГИБДД)
    case RuleId

    /// Номер исполнительного производства
    case ExecId

    /// Код вида платежа(например, для платежей в адрес Росреестра)
    case RegType

    /// Уникальный идентификатор начисления
    case UIN

    /// Технический код, рекомендуемый для заполнения поставщиком услуг.
    case TechCode
}

extension PaymentField {
    static let required: [PaymentField] = [
        .Name,
        .PersonalAcc,
        .BankName,
        .BIC,
        .CorrespAcc
    ]

    static let additional: [PaymentField] = [
        .Sum,
        .Purpose,
        .PayeeINN,
        .PayerINN,
        .DrawerStatus,
        .KPP,
        .CBC,
        .OKTMO,
        .PaytReason,
        .TaxPeriod,
        .DocNo,
        .DocDate,
        .TaxPaytKind
    ]

    static let other: [PaymentField] = [
        .LastName,
        .FirstName,
        .MiddleName,
        .PayerAddress,
        .PersonalAccount,
        .DocIdx,
        .PensAccNo,
        .Contract,
        .PersAcc,
        .Flat,
        .Phone,
        .PayerIdType,
        .PayerIdNum,
        .ChildFio,
        .BirthDate,
        .PaymTerm,
        .PaymPeriod,
        .Category,
        .ServiceName,
        .CounterId,
        .CounterVal,
        .QuittId,
        .QuittDate,
        .InstNum,
        .ClassNum,
        .SpecFio,
        .AddAmount,
        .RuleId,
        .ExecId,
        .RegType,
        .UIN,
        .TechCode
    ]

}
