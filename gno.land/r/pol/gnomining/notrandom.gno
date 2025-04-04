// i couldnt import it from p/paulogarithm/notrandom

package gnomining

// import "time"

// var RANDOM_MACHINE = &Machine{Seed: uint64(time.Now().Unix())}

// type Machine struct {
// 	Seed uint64
// }

// func MachineXorshift64star() uint64 {
// 	RANDOM_MACHINE.Seed ^= RANDOM_MACHINE.Seed >> 12
// 	RANDOM_MACHINE.Seed ^= RANDOM_MACHINE.Seed << 25
// 	RANDOM_MACHINE.Seed ^= RANDOM_MACHINE.Seed >> 27
// 	return RANDOM_MACHINE.Seed * 2685821657736338717
// }

// func MachineRandFloat() float64 {
// 	return float64(MachineXorshift64star()>>11) / (1 << 53)
// }

// func IAbs(x int) int {
// 	if (x < 0) {
// 		return -x
// 	} else {
// 		return x
// 	}
// }

// func (*Machine) RandInt(min, max int) int {
// 	return (IAbs(RANDOM_MACHINE.GenerateInt()) % ((max - min) + 1)) + min
// }

// func MachineGenerateInt() int {
// 	return int(MachineXorshift64star())
// }
