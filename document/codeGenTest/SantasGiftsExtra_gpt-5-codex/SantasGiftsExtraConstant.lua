local SantasGiftsExtraConstant = {}

SantasGiftsExtraConstant.SYMBOL_ID = {
    S01 = 0,
    B01 = 1,
    B02 = 2,
    H01 = 3,
    H02 = 4,
    H03 = 5,
    L01 = 6,
    L02 = 7
}

SantasGiftsExtraConstant.B01_TYPE = {
    VALUE = "value",
    FREE_SPIN = "free_spin",
    JACKPOT = "jackpot"
}

SantasGiftsExtraConstant.B02_TYPE = {
    EXTRA = "extra",
    EXTRA2 = "extra2",
    EXTRA3 = "extra3"
}

SantasGiftsExtraConstant.B01_VALUE_SEQUENCE = {
    0.2,
    0.5,
    1,
    2,
    3,
    5,
    10,
    15,
    20
}

SantasGiftsExtraConstant.B02_VALUE_MULTIPLIER = {
    [SantasGiftsExtraConstant.B02_TYPE.EXTRA] = 2,
    [SantasGiftsExtraConstant.B02_TYPE.EXTRA2] = 3,
    [SantasGiftsExtraConstant.B02_TYPE.EXTRA3] = 4
}

SantasGiftsExtraConstant.B02_FREE_SPIN_BONUS = {
    [SantasGiftsExtraConstant.B02_TYPE.EXTRA] = 5,
    [SantasGiftsExtraConstant.B02_TYPE.EXTRA2] = 10,
    [SantasGiftsExtraConstant.B02_TYPE.EXTRA3] = 15
}

SantasGiftsExtraConstant.B02_JACKPOT_REMOVE_LEVEL = {
    [SantasGiftsExtraConstant.B02_TYPE.EXTRA] = 1,
    [SantasGiftsExtraConstant.B02_TYPE.EXTRA2] = 2
}

SantasGiftsExtraConstant.B01_FREE_SPIN_VALUE = {
    [5] = true,
    [10] = true
}

SantasGiftsExtraConstant.B01_VALUE_LOOKUP = {}
for _, value in ipairs(SantasGiftsExtraConstant.B01_VALUE_SEQUENCE) do
    SantasGiftsExtraConstant.B01_VALUE_LOOKUP[value] = true
end

return SantasGiftsExtraConstant

