# Battle

**Warriors!**

The war has started! There are battles to enlist in, and glory to claim!

You can now use your Loot Weapon in battle against other warriors.

## Creating a battle

If you want to create a battle, use the `startBattle` function in the Etherscan:

https://etherscan.io/address/0x5be515103ae8f2f759a6e74cd4bcd26a518fd103#writeContract

You'll be able to choose how long (in seconds) the battle will last. E.g. choose 3600 if
you want an hour-long battle, or 86400 for a day-long struggle.

## Joining a battle

To enlist in a battle, first find the `battleId` for a battle you want to
participate in. Find it out from your fellow warriors. Then, you can interact
with the battle on Etherscan; the contract is here:

https://etherscan.io/address/0x56ddd8167164da0c0c48e1e9a904553f3571c5b6#readContract

You can find out the current state of the battle by reading the
`idToBattleInfo` function. That will tell you how many warriors are involved,
and what the power of the attackers and defenders is.

To enlist, select "write contract" or follow this url:

https://etherscan.io/address/0x56ddd8167164da0c0c48e1e9a904553f3571c5b6#writeContract

Then, click connect to web3 and choose the `enlist` function. Add in the
battleId, the id of the weapon you want to use, and which side you're joining.
Use side `1` to join the attackers, or side `2` to support the defenders.

If it gives you a super high gas amount, that might mean that you've already
enlisted in that battle, or your weapon is already in use for that battle, or
it's too late to participate in that battle.

## Redeeming rewards

We are hard at work on launching the rewards contract so you can redeem your
winnings in LWXP. You will be able to claim for all battles, retrospectively
too.
