{:user {:jvm-opts ["-Dapple.awt.UIElement=true"]
        :dependencies [[criterium "0.4.3"]
                       [pjstadig/humane-test-output "0.6.0"]]
        :plugins [[cider/cider-nrepl "0.8.2-SNAPSHOT"]
                  [com.cemerick/austin "0.1.5"]
                  [com.jakemccrary/lein-test-refresh "0.5.0"]
                  [jonase/eastwood "0.1.4"]
                  [lein-ancient "0.5.5"]
                  [lein-annotations "0.1.0"]
                  [lein-bikeshed "0.1.7"]
                  [lein-kibit "0.0.8"]
                  [refactor-nrepl "0.2.2"]]
        :injections [(require 'pjstadig.humane-test-output)
                     (pjstadig.humane-test-output/activate!)]}}
