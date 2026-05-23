// Odin has no user macros. Metaprogramming = generics + `when` +
// runtime introspection via core:reflect.
//
// Same shape as 5-Zig, but the switch runs at runtime against
// `Type_Info` instead of comptime against `@typeInfo`. `any` is a fat
// pointer of `{data, type_id}` — the runtime dual of `anytype`.
// Unsupported types fall through to `%v` here; Zig `@compileError`s.

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
			field_val := any {
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

// Print the runtime type table `write_value` dispatches on.
dump_type_info :: proc(v: any) {
	ti := reflect.type_info_base(type_info_of(v.id))
	fmt.printf("Type_Info for %v:\n", ti)
	#partial switch info in ti.variant {
	case reflect.Type_Info_Struct:
		n := reflect.struct_field_count(v.id)
		for i in 0 ..< n {
			f := reflect.struct_field_at(v.id, i)
			fmt.printf("  [%d] %s: %v (offset=%d)\n", i, f.name, f.type, f.offset)
		}
	}
}

main :: proc() {
	u := User {
		id     = 42,
		name   = "alice",
		email  = "a@x.com",
		active = true,
	}

	dump_type_info(u)

	out := to_json(u)
	defer delete(out)
	fmt.println(out)
}
