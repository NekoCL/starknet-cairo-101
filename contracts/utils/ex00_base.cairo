######### Ex 00
## A contract from which other contracts can import functions

%lang starknet

from contracts.token.ITDERC20 import ITDERC20
from contracts.utils.Iplayers_registry import Iplayers_registry
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt, uint256_check
)
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import (get_contract_address)
#
# Declaring storage vars
# Storage vars are by default not visible through the ABI. They are similar to "private" variables in Solidity
#

@storage_var
func tderc20_address_storage() -> (tderc20_address_storage : felt):
end

@storage_var
func players_registry_storage() -> (tderc20_address_storage : felt):
end

@storage_var
func workshop_id_storage() -> (workshop_id_storage : felt):
end

@storage_var
func exercise_id_storage() -> (exercise_id_storage : felt):
end
#
# Declaring getters
# Public variables should be declared explicitely with a getter
#

@view
func tderc20_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_tderc20_address: felt):
    let (_tderc20_address) = tderc20_address_storage.read()
    return (_tderc20_address)
end

@view
func players_registry{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_players_registry: felt):
    let (_players_registry) = players_registry_storage.read()
    return (_players_registry)
end

@view
func workshop_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_workshop_id: felt):
    let (_workshop_id) = workshop_id_storage.read()
    return (_workshop_id)
end

@view
func exercise_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (_exercise_id: felt):
    let (_exercise_id) = exercise_id_storage.read()
    return (_exercise_id)
end


@view
func has_validated_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt) -> (has_validated_exercice: felt):
    # reading player registry
	let (_players_registry) = players_registry_storage.read()
	let (_workshop_id) = workshop_id_storage.read()
	let (_exercise_id) = exercise_id_storage.read()
	# Checking if the user already validated this exercice
	let (has_current_user_validated_exercice) = Iplayers_registry.has_validated_exercice(contract_address=_players_registry, account=account, workshop=_workshop_id, exercise = _exercise_id)
    return (has_current_user_validated_exercice)
end

#
# Internal constructor
# This function is used to initialize the contract. It can be called from the constructor
#

func ex_initializer{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        _tderc20_address: felt,
        _players_registry: felt,
        _workshop_id: felt,
        _exercise_id: felt	
    ):
    tderc20_address_storage.write(_tderc20_address)
    players_registry_storage.write(_players_registry)
    workshop_id_storage.write(_workshop_id)
    exercise_id_storage.write(_exercise_id)
    return ()
end

#
# Internal functions
# These functions can not be called directly by a transaction
# Similar to internal functions in Solidity
#

func distribute_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(to: felt, amount: felt):
	
	# Converting felt to uint256. We assume it's a small number 
	# We also add the required number of decimals
	let points_to_credit: Uint256 = Uint256(amount*1000000000000000000, 0)
	# Retrieving contract address from storage
	let (contract_address) = tderc20_address_storage.read()
	# Calling the ERC20 contract to distribute points
	ITDERC20.distribute_points(contract_address=contract_address, to = to, amount = points_to_credit)
	return()
end


func validate_exercise{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(account: felt):
	# reading player registry
	let (_players_registry) = players_registry_storage.read()
	let (_workshop_id) = workshop_id_storage.read()
	let (_exercise_id) = exercise_id_storage.read()
	# Checking if the user already validated this exercice
	let (has_current_user_validated_exercice) = Iplayers_registry.has_validated_exercice(contract_address=_players_registry, account=account, workshop=_workshop_id, exercise = _exercise_id)
	assert (has_current_user_validated_exercice) = 0

	# Marking the exercice as completed
	Iplayers_registry.validate_exercice(contract_address=_players_registry, account=account, workshop=_workshop_id, exercise = _exercise_id)
	

	return()
end








