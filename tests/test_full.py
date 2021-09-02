from brownie import Contract, WeaponStats
import brownie
import pytest

@pytest.fixture
def dai():
    yield Contract.from_explorer("0x6B175474E89094C44Da98b954EedeAC495271d0F")


def test_full(accounts, WeaponStats):
    wep = WeaponStats.deploy({"from": accounts[0]})
    looter = brownie.accounts.at("0x009988Ff77eEaa00051238ee32C48f10a174933E", force=True)
    wep.claimForLoot(1855, {"from": looter})
    print(wep.ownerOf(1855))
    print(wep.tokenURI(1855))


def test_blacksmith(accounts, WeaponStats, dai):
    wep = WeaponStats.deploy({"from": accounts[0]})
    wep.setToken("0x6B175474E89094C44Da98b954EedeAC495271d0F", {"from": accounts[0]})
    wep.setBoostCoefficient(1e18, {"from": accounts[0]})
    whale = brownie.accounts.at("0x6F6C07d80D0D433ca389D336e6D1feBEA2489264", force=True)
    wep.claim(9000, {"from": whale})
    print(wep.tokenURI(9000, {"from": accounts[0]}))
    with brownie.reverts():
        wep.weaponSmith(9000, 100e18, {"from": whale})
    wep.setWeaponSmithOpen(True, {"from": accounts[0]})
    dai.approve(wep.address, 100e18, {"from": whale})
    tx = wep.weaponSmith(9000, 100e18, {"from": whale})
    print(tx.events)
    print(wep.tokenURI(9000, {"from": accounts[0]}))
    wep.sweep(dai.address, 100e18, {"from": accounts[0]})
    print(dai.balanceOf(accounts[0]))