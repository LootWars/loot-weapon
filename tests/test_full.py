from brownie import Contract, WeaponStats


def test_full(accounts, WeaponStats):
    wep = WeaponStats.deploy({"from": accounts[0]})
    print(wep.tokenURI(7086, {"from": accounts[0]}))