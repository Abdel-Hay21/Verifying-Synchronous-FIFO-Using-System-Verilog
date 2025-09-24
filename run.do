vlib work
vlog *.sv  +cover -covercells +define+SIM
vsim -voptargs=+acc work.top -cover 
coverage save FIFO.ucdb -onexit -du FIFO
do wave.do
run -all

vcover report FIFO.ucdb -details -annotate -all -output Report.txt

