onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {Clock / Reset}
add wave -noupdate -divider <NULL>
add wave -noupdate /aes128_top/duv_wrapper/duv/Clk_CI
add wave -noupdate /aes128_top/duv_wrapper/duv/Reset_RBI
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DUV I/Os}
add wave -noupdate -divider <NULL>
add wave -noupdate /aes128_top/duv_wrapper/duv/Start_SI
add wave -noupdate /aes128_top/duv_wrapper/duv/NewCipherkey_SI
add wave -noupdate /aes128_top/duv_wrapper/duv/Busy_SO
add wave -noupdate /aes128_top/duv_wrapper/duv/Plaintext_DI
add wave -noupdate /aes128_top/duv_wrapper/duv/Cipherkey_DI
add wave -noupdate /aes128_top/duv_wrapper/duv/Ciphertext_DO
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {161 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {201 ns}
