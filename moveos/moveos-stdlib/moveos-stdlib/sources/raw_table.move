// Copyright (c) RoochNetwork
// SPDX-License-Identifier: Apache-2.0

/// Raw Key Value table. This is the basic of storage abstraction.
/// This type table doesn't care about the key and value types. We leave the data type checking to the Native implementation.
/// This type table is for internal global storage, so all functions are friend.

module moveos_std::raw_table {
    use moveos_std::object_id::ObjectID;

    friend moveos_std::object;

    /// The key already exists in the table
    const ErrorAlreadyExists: u64 = 1;
    /// Can not found the key in the table
    const ErrorNotFound: u64 = 2;
    /// Duplicate operation on the table
    const ErrorDuplicateOperation: u64 = 3;
    /// The table is not empty
    const ErrorNotEmpty: u64 = 4;
    /// The table already exists
    const ErrorTableAlreadyExists: u64 = 5;


    /// Information about a specific table info type. Stored in the global Object storage.
    struct TableInfo has key, store, drop {
        // Table SMT root
        state_root: address,
        // Table size, number of items
        size: u64,
    }

    public fun state_root(table_info: &TableInfo): address {
        table_info.state_root
    }

    public fun size(table_info: &TableInfo): u64 {
        table_info.size
    }

    /// Add a new entry to the table. Aborts if an entry for this
    /// key already exists. The entry itself is not stored in the
    /// table, and cannot be discovered from it.
    public(friend) fun add<K: copy + drop, V>(table_handle: ObjectID, key: K, val: V) {
        add_box<K, V, Box<V>>(table_handle, key, Box {val} );
    }

    /// Acquire an immutable reference to the value which `key` maps to.
    /// Aborts if there is no entry for `key`.
    public(friend) fun borrow<K: copy + drop, V>(table_handle: ObjectID, key: K): &V {
        &borrow_box<K, V, Box<V>>(table_handle, key).val
    }

    /// Acquire an immutable reference to the value which `key` maps to.
    /// Returns specified default value if there is no entry for `key`.
    public(friend) fun borrow_with_default<K: copy + drop, V>(table_handle: ObjectID, key: K, default: &V): &V {
        if (!contains<K>(table_handle, key)) {
            default
        } else {
            borrow(table_handle, key)
        }
    }

    /// Acquire a mutable reference to the value which `key` maps to.
    /// Aborts if there is no entry for `key`.
    public(friend) fun borrow_mut<K: copy + drop, V>(table_handle: ObjectID, key: K): &mut V {
        &mut borrow_box_mut<K, V, Box<V>>(table_handle, key).val
    }

    /// Acquire a mutable reference to the value which `key` maps to.
    /// Insert the pair (`key`, `default`) first if there is no entry for `key`.
    public(friend) fun borrow_mut_with_default<K: copy + drop, V: drop>(table_handle: ObjectID, key: K, default: V): &mut V {
        if (!contains<K>(table_handle, copy key)) {
            add(table_handle, key, default)
        };
        borrow_mut(table_handle, key)
    }

    /// Insert the pair (`key`, `value`) if there is no entry for `key`.
    /// update the value of the entry for `key` to `value` otherwise
    public(friend) fun upsert<K: copy + drop, V: drop>(table_handle: ObjectID, key: K, value: V) {
        if (!contains<K>(table_handle, copy key)) {
            add(table_handle, key, value)
        } else {
            let ref = borrow_mut(table_handle, key);
            *ref = value;
        };
    }

    /// Remove from `table` and return the value which `key` maps to.
    /// Aborts if there is no entry for `key`.
    public(friend) fun remove<K: copy + drop, V>(table_handle: ObjectID, key: K): V {
        let Box { val } = remove_box<K, V, Box<V>>(table_handle, key);
        val
    }

    /// Returns true if `table` contains an entry for `key`.
    public(friend) fun contains<K: copy + drop>(table_handle: ObjectID, key: K): bool {
        contains_box<K>(table_handle, key)
    }

    /// Returns the size of the table, the number of key-value pairs
    public(friend) fun length(table_handle: ObjectID): u64 {
        box_length(table_handle)
    }

    /// Returns true if the table is empty (if `length` returns `0`)
    public(friend) fun is_empty(table_handle: ObjectID): bool {
        length(table_handle) == 0
    }

    /// Drop a table even if it is not empty.
    public(friend) fun drop_unchecked(table_handle: ObjectID) {
        drop_unchecked_box(table_handle)
    }
    
    /// Destroy a table. Aborts if the table is not empty
    public(friend) fun destroy_empty(table_handle: ObjectID) {
        assert!(is_empty(table_handle), ErrorNotEmpty);
        drop_unchecked_box(table_handle)
    }

    // ======================================================================================================
    // Internal API
    
    /// Wrapper for values. Required for making values appear as resources in the implementation.
    /// Because the GlobalValue in MoveVM must be a resource.
    struct Box<V> has key, drop, store {
        val: V
    }

    /// New a table. Aborts if the table exists.
    native public(friend) fun new_table(table_handle: ObjectID): TableInfo;

    native fun add_box<K: copy + drop, V, B>(table_handle: ObjectID, key: K, val: Box<V>);

    native fun borrow_box<K: copy + drop, V, B>(table_handle: ObjectID, key: K): &Box<V>;

    native fun borrow_box_mut<K: copy + drop, V, B>(table_handle: ObjectID, key: K): &mut Box<V>;

    native fun contains_box<K: copy + drop>(table_handle: ObjectID, key: K): bool;

    native fun remove_box<K: copy + drop, V, B>(table_handle: ObjectID, key: K): Box<V>;

    native fun drop_unchecked_box(table_handle: ObjectID);

    native fun box_length(table_handle: ObjectID): u64;
}
