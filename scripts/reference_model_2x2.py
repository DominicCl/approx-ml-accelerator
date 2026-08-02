W00, W01, W10, W11 = 1, 2, 3, 4

act_c1 = {0: 5, 1: 7}
act_c3 = {1: 6, 2: 8}

cell1_out = {}
cell2_out = {}
cell3_out = {}
cell4_out = {}
act_c1_reg = {}
act_c3_reg = {}

for t in range(6):
    a1 = act_c1.get(t-1, 0)
    cell1_out[t] = a1 * W00
    act_c1_reg[t] = a1

    a3 = act_c3.get(t-1, 0)
    cell3_out[t] = a3 * W10 + cell1_out.get(t-1, 0)
    act_c3_reg[t] = a3

    a2 = act_c1_reg.get(t-1, 0)
    cell2_out[t] = a2 * W01

    a4 = act_c3_reg.get(t-1, 0)
    cell4_out[t] = a4 * W11 + cell2_out.get(t-1, 0)

    print(f"t={t}: c1={cell1_out[t]:>3} c2={cell2_out[t]:>3} c3={cell3_out[t]:>3} c4={cell4_out[t]:>3}")

print()
print("A=[5 6;7 8], W(=B)=[1 2;3 4]")
print("expect C00=23 C01=34 C10=31 C11=46")
