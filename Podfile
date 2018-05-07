# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

use_frameworks!

def cannonball_pods
    use_frameworks!

    # Pods for Cannonball
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'FirebaseUI/Auth'
    pod 'FirebaseUI/Phone'
    pod 'Firebase/Database'
    pod 'FirebaseUI/Database'

    pod 'Fabric', '~> 1.7.6'
    pod 'Crashlytics', '~> 3.10.1'
end

target 'Cannonball Dev' do
    cannonball_pods
end

target 'Cannonball Prod' do
    cannonball_pods
end
