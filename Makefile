
export EXTENSION_NAME = AEPEdgeMedia
export APP_NAME = TestApp
PROJECT_NAME = $(EXTENSION_NAME)
TARGET_NAME_XCFRAMEWORK = $(EXTENSION_NAME).xcframework
SCHEME_NAME_XCFRAMEWORK = $(EXTENSION_NAME)
UNIT_TEST_SCHEME = UnitTests
FUNCTIONAL_TEST_SCHEME = FunctionalTests
INTEGRATION_TEST_SCHEME = IntegrationTests


CURR_DIR := ${CURDIR}
IOS_SIMULATOR_ARCHIVE_PATH = $(CURR_DIR)/build/ios_simulator.xcarchive/Products/Library/Frameworks/
IOS_SIMULATOR_ARCHIVE_DSYM_PATH = $(CURR_DIR)/build/ios_simulator.xcarchive/dSYMs/
IOS_ARCHIVE_PATH = $(CURR_DIR)/build/ios.xcarchive/Products/Library/Frameworks/
IOS_ARCHIVE_DSYM_PATH = $(CURR_DIR)/build/ios.xcarchive/dSYMs/
TVOS_SIMULATOR_ARCHIVE_PATH = ./build/tvos_simulator.xcarchive/Products/Library/Frameworks/
TVOS_SIMULATOR_ARCHIVE_DSYM_PATH = $(CURR_DIR)/build/tvos_simulator.xcarchive/dSYMs/
TVOS_ARCHIVE_PATH = ./build/tvos.xcarchive/Products/Library/Frameworks/
TVOS_ARCHIVE_DSYM_PATH = $(CURR_DIR)/build/tvos.xcarchive/dSYMs/

setup:
	(pod install)

setup-tools: install-githook

pod-repo-update:
	(pod repo update)

# pod repo update may fail if there is no repo (issue fixed in v1.8.4). Use pod install --repo-update instead
pod-install:
	(pod install --repo-update)

ci-pod-install:
	(bundle exec pod install --repo-update)

pod-update: pod-repo-update
	(pod update)

open:
	open $(PROJECT_NAME).xcworkspace

clean:
	(rm -rf build)

build-app:
	#make -C TestApps/$(APP_NAME) build-shallow

archive: pod-update
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/ios.xcarchive" -sdk iphoneos -destination="iOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/tvos.xcarchive" -sdk appletvos -destination="tvOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/ios_simulator.xcarchive" -sdk iphonesimulator -destination="iOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/tvos_simulator.xcarchive" -sdk appletvsimulator -destination="tvOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild -create-xcframework -framework $(IOS_SIMULATOR_ARCHIVE_PATH)$(PROJECT_NAME).framework -debug-symbols $(IOS_SIMULATOR_ARCHIVE_DSYM_PATH)$(PROJECT_NAME).framework.dSYM \
	-framework $(TVOS_SIMULATOR_ARCHIVE_PATH)$(PROJECT_NAME).framework -debug-symbols $(TVOS_SIMULATOR_ARCHIVE_DSYM_PATH)$(PROJECT_NAME).framework.dSYM \
	-framework $(IOS_ARCHIVE_PATH)$(PROJECT_NAME).framework -debug-symbols $(IOS_ARCHIVE_DSYM_PATH)$(PROJECT_NAME).framework.dSYM \
	-framework $(TVOS_ARCHIVE_PATH)$(PROJECT_NAME).framework -debug-symbols $(TVOS_ARCHIVE_DSYM_PATH)$(PROJECT_NAME).framework.dSYM \
	-output ./build/$(TARGET_NAME_XCFRAMEWORK)

test-ios:
	@echo "######################################################################"
	@echo "### Testing iOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME) -destination 'platform=iOS Simulator,name=iPhone 8' -derivedDataPath build/outn -resultBundlePath iosresults.xcresult -enableCodeCoverage YES

test-tvos:
	@echo "######################################################################"
	@echo "### Testing tvOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME) -destination 'platform=tvOS Simulator,name=Apple TV' -derivedDataPath build/outn -resultBundlePath tvosresults.xcresult -enableCodeCoverage YES

unit-test-ios:
	@echo "######################################################################"
	@echo "### Unit Testing iOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(UNIT_TEST_SCHEME) -destination 'platform=iOS Simulator,name=iPhone 8' -derivedDataPath build/outn -resultBundlePath iosunittestresults.xcresult -enableCodeCoverage YES

unit-test-tvos:
	@echo "######################################################################"
	@echo "### Unit Testing tvOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(UNIT_TEST_SCHEME) -destination 'platform=tvOS Simulator,name=Apple TV' -derivedDataPath build/outn -resultBundlePath tvosunittestresults.xcresult -enableCodeCoverage YES

functional-test-ios:
	@echo "######################################################################"
	@echo "### Functional Testing iOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(FUNCTIONAL_TEST_SCHEME) -destination 'platform=iOS Simulator,name=iPhone 8' -derivedDataPath build/outn -resultBundlePath iosfunctionaltestresults.xcresult -enableCodeCoverage YES

functional-test-tvos:
	@echo "######################################################################"
	@echo "### Functional Testing tvOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(FUNCTIONAL_TEST_SCHEME) -destination 'platform=tvOS Simulator,name=Apple TV' -derivedDataPath build/outn -resultBundlePath tvosfunctionaltestresults.xcresult  -enableCodeCoverage YES

integration-test-ios:
	@echo "######################################################################"
	@echo "### Integration Testing iOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(INTEGRATION_TEST_SCHEME) -destination 'platform=iOS Simulator,name=iPhone 8' -derivedDataPath build/outn -resultBundlePath iosintegrationtestresults.xcresult -enableCodeCoverage YES

integration-test-tvos:
	@echo "######################################################################"
	@echo "### Integration Testing tvOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(INTEGRATION_TEST_SCHEME) -destination 'platform=tvOS Simulator,name=Apple TV' -derivedDataPath build/outn -resultBundlePath tvosintegrationtestresults.xcresult -enableCodeCoverage YES


install-githook:
	./tools/git-hooks/setup.sh

lint-autocorrect:
	(./Pods/SwiftLint/swiftlint autocorrect --format)

lint:
	(./Pods/SwiftLint/swiftlint lint Sources TestApps/$(APP_NAME))

check-version:
	(sh ./Script/version.sh $(VERSION))

test-SPM-integration:
	(sh ./Script/test-SPM.sh)

test-podspec:
	(sh ./Script/test-podspec.sh)
