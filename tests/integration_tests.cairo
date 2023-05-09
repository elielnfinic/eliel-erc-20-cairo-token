use nfinic_erc20::ERC20::ERC20;
use starknet::contract_address_const;
use starknet::ContractAddress;
use integer::u256;
use integer::u256_from_felt252;
use starknet::testing::set_caller_address;

fn setup() -> ContractAddress{
    let initial_supply : u256 = u256_from_felt252(2000);
    let decimals : u8 = 18_u8;
    let name : felt252 = 'ELIEL';
    let symbol : felt252 = 'ELI';
    let account : ContractAddress = contract_address_const::<1>();
    set_caller_address(account);
    ERC20::constructor(name, symbol, decimals, initial_supply, account);
    account
}

#[test]
#[available_gas(2000000)]
fn test_transfer() {
    let owner = setup();
    let recipient : ContractAddress = contract_address_const::<2>();
    assert(recipient != owner, 'ERC20: account is not the same');
    assert(ERC20::get_name() == 'ELIEL', 'ERC20: name is not set');
    let amount = u256_from_felt252(100);
    ERC20::transfer(recipient, amount);
    let recipient_bal = ERC20::balance_of(recipient);
    let account_bal = ERC20::balance_of(owner);

    assert(recipient_bal == u256_from_felt252(100), 'ERC20: recipient got funds');
    assert(account_bal == u256_from_felt252(1900), 'ERC20: owner sent funds');
}

