test:
	v test .

docs:
	v doc .

link:
	ln -sf $(PWD) ~/.vmodules/cuiqcharts

example-basic:
	v run examples/basic/main.v

example-dashboard:
	v run examples/dashboard/main.v
