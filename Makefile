.PHONY: devbuild db distbuild


devbuild db:
	# Builds the devbuild aggregate target
	. ${COMMON_SCRIPTS_HOME}/DevBuild.sh

distbuild:
	#Builds the Distribution build target
	python ${COMMON_SCRIPTS_HOME}/DistributionBuild.py
	. ${COMMON_SCRIPTS_HOME}/EnterprisePackageApplication.sh

testflightdist:
	python ${COMMON_SCRIPTS_HOME}/DistributionBuild.py
	. ${COMMON_SCRIPTS_HOME}/TestFlightDistribute.sh

alldist:
	python ${COMMON_SCRIPTS_HOME}/DistributionBuild.py
	. ${COMMON_SCRIPTS_HOME}/EnterprisePackageApplication.sh
	. ${COMMON_SCRIPTS_HOME}/TestFlightDistribute.sh

