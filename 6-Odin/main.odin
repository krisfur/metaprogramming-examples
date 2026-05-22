// Odin doesn't do user-defined codegen (no macros, no proc macros).
// Its "metaprogramming" is mostly:
//   - parametric polymorphism (generics)  -- `proc(v: $T)`
//   - compile-time `when` branches
//   - runtime type introspection via core:reflect
//
// Here, `to_json` is a single parametric procedure that walks any
// struct's fields at runtime using the Type_Info attached to `any`.

package main

import "core:fmt"
import "core:reflect"
import "core:strings"

User :: struct {
	id:     u32,
	name:   string,
	email:  string,
	active: bool,
}

write_value :: proc(sb: ^strings.Builder, v: any) {
	ti := reflect.type_info_base(type_info_of(v.id))
	#partial switch info in ti.variant {
	case reflect.Type_Info_Struct:
		strings.write_byte(sb, '{')
		n := reflect.struct_field_count(v.id)
		for i in 0 ..< n {
			f := reflect.struct_field_at(v.id, i)
			if i > 0 do strings.write_byte(sb, ',')
			fmt.sbprintf(sb, "\"%s\":", f.name)
			field_val := any{
				data = rawptr(uintptr(v.data) + f.offset),
				id   = f.type.id,
			}
			write_value(sb, field_val)
		}
		strings.write_byte(sb, '}')
	case reflect.Type_Info_String:
		fmt.sbprintf(sb, "\"%s\"", (cast(^string)v.data)^)
	case reflect.Type_Info_Boolean:
		strings.write_string(sb, (cast(^bool)v.data)^ ? "true" : "false")
	case reflect.Type_Info_Integer:
		fmt.sbprintf(sb, "%v", v)
	case:
		fmt.sbprintf(sb, "%v", v)
	}
}

to_json :: proc(v: any) -> string {
	sb := strings.builder_make()
	write_value(&sb, v)
	return strings.to_string(sb)
}

main :: proc() {
	u := User{id = 42, name = "alice", email = "a@x.com", active = true}
	fmt.println(to_json(u))
}
