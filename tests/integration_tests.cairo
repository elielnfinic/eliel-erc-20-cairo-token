use nfinic_erc20::ERC20::ERC20;
use starknet::contract_address_const;
use starknet::ContractAddress;
use integer::u256;
use integer::u256_from_felt252;
use starknet::testing::set_caller_address;
use starknet::get_caller_address;

const NAME : felt252 = 'ELIEL';
const SYMBOL : felt252 = 'EL';

fn setup() -> (ContractAddress, u256) {
    let initial_supply : u256 = u256_from_felt252(2000);
    let decimals : u8 = 18_u8;

    let account : ContractAddress = contract_address_const::<1>();
    set_caller_address(account);
    ERC20::constructor(NAME, SYMBOL, decimals, initial_supply, account);
    (account, initial_supply)
}

fn setup2() -> (ContractAddress, u256) {
    let initial_supply : u256 = u256_from_felt252(2000);
    let decimals : u8 = 18_u8;

    let account : ContractAddress = contract_address_const::<1>();
    ERC20::constructor(NAME, SYMBOL, decimals, initial_supply, account);
    (account, initial_supply)
}

#[test]
#[available_gas(2000000)]
fn test_transfer() {
    setup();
    let account = get_caller_address();
    let recipient : ContractAddress = contract_address_const::<2>();
    assert(recipient != account, 'ERC20: account is not the same');
    assert(ERC20::get_name() == 'ELIEL', 'ERC20: name is not set');
    let amount = u256_from_felt252(100);
    ERC20::transfer(recipient, amount);
    let recipient_bal = ERC20::balance_of(recipient);
    let account_bal = ERC20::balance_of(account);

    assert(recipient_bal == u256_from_felt252(100), 'ERC20: recipient got funds');
    assert(account_bal == u256_from_felt252(1900), 'ERC20: owner sent funds');
}

#[test]
#[available_gas(2000000)]
#[should_panic]
fn test_transfer_to_zero() {
    let (owner, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<0>();
    let amount: u256 = u256_from_felt252(100);
    ERC20::transfer(recipient, amount);
}


#[test]
#[available_gas(2000000)]
fn test_transfer_from(){
    setup();
    let owner : ContractAddress = get_caller_address();
    let spender : ContractAddress = contract_address_const::<2>();
    let receiver : ContractAddress = contract_address_const::<3>();

    //Send some funds to account 
    let account_1 : ContractAddress = contract_address_const::<4>();
    ERC20::transfer(account_1, u256_from_felt252(500));

    assert(ERC20::balance_of(account_1) == u256_from_felt252(500), 'ERC20: ac_1 got funds');

    //Make spender, 300 ELI spender of account_1 
    set_caller_address(account_1);
    ERC20::approve(spender, u256_from_felt252(300));

    assert(ERC20::allowance(account_1, spender) == u256_from_felt252(300), 'ERC20: sp spends 300');

    //Transfer 100 ELI to reciever from account_1 by spender 
    set_caller_address(spender);
    ERC20::transfer_from(account_1, receiver, u256_from_felt252(100));

    assert(ERC20::balance_of(receiver) == u256_from_felt252(100), 'ERC20: rcv got funds');

    assert(ERC20::balance_of(account_1) == u256_from_felt252(400), 'ERC20: ac has 400');
    assert(ERC20::balance_of(owner) == u256_from_felt252(1500), 'ERC20: balance not okay');
}
