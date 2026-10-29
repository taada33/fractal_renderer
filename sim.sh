#command will be as follows:
#sim.sh modulename ""/gui/file

if [ "$1" == "clean" ]; then
    rm -f ./tb/outputs/*
    echo "Cleaned tb/outputs"
    exit 0
fi

name=$1
output=$2

tbname="${name}_tb"
simname="${name}_tb_sim"

if [ ! -f tb/${tbname}.sv ]; then
    echo "Error: Invalid testbench name!" >&2
    exit 1
fi

case $output in 
    gui)
        xvlog.bat -sv tb/${tbname}.sv rtl/*.sv && 
        xelab.bat ${tbname} -debug all -s ${simname} &&
        if [ -f tb/${name}_tb_sim.wcfg ]; then
            xsim.bat ${simname} -gui -view tb/${name}_tb_sim.wcfg
        else    
            xsim.bat ${simname} -gui
        fi
    ;;
    file)
        mkdir -p tb/outputs
        xvlog.bat -sv tb/${tbname}.sv rtl/*.sv > tb/outputs/xvlog.log 2>&1 && 
        xelab.bat ${tbname} -s ${simname} > tb/outputs/xelab.log 2>&1 &&
        xsim.bat ${simname} -R > tb/outputs/${tbname}_output.txt 2>&1
    ;;
    "")
        mkdir -p tb/outputs
        xvlog.bat -sv tb/${tbname}.sv rtl/*.sv > tb/outputs/xvlog.log 2>&1 && 
        xelab.bat ${tbname} -s ${simname} > tb/outputs/xelab.log 2>&1 &&
        xsim.bat ${simname} -R
    ;;
    *)
    #invalid option
    echo "Error: Invalid output option!" >&2
    exit 1
    ;;
esac


