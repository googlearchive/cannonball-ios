# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

use_frameworks!

def cannonball_pods
    use_frameworks!

    # Pods for Cannonball
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Firestore'
    pod 'FirebaseUI/Auth'
    pod 'FirebaseUI/Phone'
    pod 'FirebaseUI/Database'

    pod 'Fabric'
    pod 'Crashlytics'
end

target 'Cannonball Dev' do
    cannonball_pods
end

target 'Cannonball Prod' do
    cannonball_pods
end
