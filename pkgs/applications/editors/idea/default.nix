{ stdenv, fetchurl, makeDesktopItem, makeWrapper, patchelf, p7zip, jdk
, coreutils, gnugrep, which, git, python, unzip, androidsdk
}:

assert stdenv.isLinux;

let

  mkIdeaProduct = with stdenv.lib;
  { name, product, version, build, src, meta }:

  let loName = toLower product;
      hiName = toUpper product;
      execName = concatStringsSep "-" (init (splitString "-" name));
  in

  with stdenv; lib.makeOverridable mkDerivation rec {
    inherit name build src meta;
    desktopItem = makeDesktopItem {
      name = execName;
      exec = execName;
      comment = lib.replaceChars ["\n"] [" "] meta.longDescription;
      desktopName = product;
      genericName = meta.description;
      categories = "Application;Development;";
      icon = execName;
    };

    buildInputs = [ makeWrapper patchelf p7zip unzip ];

    patchPhase = ''
        get_file_size() {
          local fname="$1"
          echo $(ls -l $fname | cut -d ' ' -f5)
        }

        munge_size_hack() {
          local fname="$1"
          local size="$2"
          strip $fname
          truncate --size=$size $fname
        }

        interpreter=$(echo ${stdenv.glibc}/lib/ld-linux*.so.2)
        if [ "${stdenv.system}" == "x86_64-linux" ]; then
          target_size=$(get_file_size bin/fsnotifier64)
          patchelf --set-interpreter "$interpreter" bin/fsnotifier64
          munge_size_hack bin/fsnotifier64 $target_size
        else
          target_size=$(get_file_size bin/fsnotifier)
          patchelf --set-interpreter "$interpreter" bin/fsnotifier
          munge_size_hack bin/fsnotifier $target_size
        fi
    '';

    installPhase = ''
      mkdir -p $out/{bin,$name,share/pixmaps,libexec/${name}}
      cp -a . $out/$name
      ln -s $out/$name/bin/${loName}.png $out/share/pixmaps/${execName}.png
      mv bin/fsnotifier* $out/libexec/${name}/.

      jdk=${jdk.home}
      item=${desktopItem}

      makeWrapper "$out/$name/bin/${loName}.sh" "$out/bin/${execName}" \
        --prefix PATH : "$out/libexec/${name},${jdk}/bin:${coreutils}/bin:${gnugrep}/bin:${which}/bin:${git}/bin" \
        --prefix JDK_HOME : "$jdk" \
        --prefix ${hiName}_JDK : "$jdk"

      ln -s "$item/share/applications" $out/share
    '';

  };

  buildAndroidStudio = { name, version, build, src, license, description }:
    let drv = (mkIdeaProduct rec {
      inherit name version build src;
      product = "Studio";
      meta = with stdenv.lib; {
        homepage = https://developer.android.com/sdk/installing/studio.html;
        inherit description license;
        longDescription = ''
          Android development environment based on IntelliJ
          IDEA providing new features and improvements over
          Eclipse ADT and will be the official Android IDE
          once it's ready.
        '';
        platforms = platforms.linux;
        maintainers = with maintainers; [ edwtjo ];
      };
    });
    in stdenv.lib.overrideDerivation drv (x : {
      buildInputs = x.buildInputs ++ [ makeWrapper ];
      installPhase = x.installPhase +  ''
        wrapProgram "$out/bin/android-studio" \
          --set ANDROID_HOME "${androidsdk}/libexec/android-sdk-linux/"
      '';
    });

  buildClion = { name, version, build, src, license, description }:
    (mkIdeaProduct rec {
      inherit name version build src;
      product = "CLion";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/clion/";
        inherit description license;
        longDescription = ''
          Enhancing productivity for every C and C++
          developer on Linux, OS X and Windows.
        '';
        maintainers = with maintainers; [ edwtjo ];
        platforms = platforms.linux;
      };
    });

  buildIdea = { name, version, build, src, license, description }:
    (mkIdeaProduct rec {
      inherit name version build src;
      product = "IDEA";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/idea/";
        inherit description license;
        longDescription = ''
          IDE for Java SE, Groovy & Scala development Powerful
          environment for building Google Android apps Integration
          with JUnit, TestNG, popular SCMs, Ant & Maven.
        '';
        maintainers = with maintainers; [ edwtjo ];
        platforms = platforms.linux;
      };
    });

  buildRubyMine = { name, version, build, src, license, description }:
    (mkIdeaProduct rec {
      inherit name version build src;
      product = "RubyMine";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/ruby/";
        inherit description license;
        longDescription = description;
        maintainers = with maintainers; [ edwtjo ];
        platforms = platforms.linux;
      };
    });

  buildPhpStorm = { name, version, build, src, license, description }:
    (mkIdeaProduct {
      inherit name version build src;
      product = "PhpStorm";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/phpstorm/";
        inherit description license;
        longDescription = ''
          PhpStorm provides an editor for PHP, HTML and JavaScript
          with on-the-fly code analysis, error prevention and
          automated refactorings for PHP and JavaScript code.
        '';
        maintainers = with maintainers; [ schristo ];
        platforms = platforms.linux;
      };
    });

  buildPycharm = { name, version, build, src, license, description }:
    (mkIdeaProduct rec {
      inherit name version build src;
      product = "PyCharm";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/pycharm/";
        inherit description license;
        longDescription = ''
          Python IDE with complete set of tools for productive
          development with Python programming language. In addition, the
          IDE provides high-class capabilities for professional Web
          development with Django framework and Google App Engine. It
          has powerful coding assistance, navigation, a lot of
          refactoring features, tight integration with various Version
          Control Systems, Unit testing, powerful all-singing
          all-dancing Debugger and entire customization. PyCharm is
          developer driven IDE. It was developed with the aim of
          providing you almost everything you need for your comfortable
          and productive development!
        '';
        maintainers = with maintainers; [ jgeerds ];
        platforms = platforms.linux;
      };
    }).override {
      propagatedUserEnvPkgs = [ python ];
    };

in

{

  android-studio = buildAndroidStudio rec {
    name = "android-studio-${version}";
    version = "1.1.0";
    build = "135.1740770";
    description = "Android development environment based on IntelliJ IDEA";
    license = stdenv.lib.licenses.asl20;
    src = fetchurl {
      url = "https://dl.google.com/dl/android/studio/ide-zips/${version}" +
            "/android-studio-ide-${build}-linux.zip";
      sha256 = "1r2hrld3yfaxq3mw2xmzhvrrhc7w5xlv3d18rv758hy9n40c2nr1";
    };
  };

  clion = buildClion rec {
    name = "clion-${build}";
    version = "eap";
    build = "141.102.4";
    description  = "C/C++ IDE. New. Intelligent. Cross-platform.";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/cpp/${name}.tar.gz";
      sha256 = "0qjm8wxqn171wfd7yqf5ys1g4mwl0iyhlbry29jkgkikxp7h9dym";
    };
  };

  idea-community = buildIdea rec {
    name = "idea-community-${version}";
    version = "14.1";
    build = "IC-141.177.4";
    description = "Integrated Development Environment (IDE) by Jetbrains, community edition";
    license = stdenv.lib.licenses.asl20;
    src = fetchurl {
      url = "https://download.jetbrains.com/idea/ideaIC-${version}.tar.gz";
      sha256 = "05irkxhmx6pisvghjalw8hcf9v3n4wn0n0zc92ahivzxlicylpr6";
    };
  };

  idea-ultimate = buildIdea rec {
    name = "idea-ultimate-${version}";
    version = "14.1";
    build = "IU-141.177.4";
    description = "Integrated Development Environment (IDE) by Jetbrains, requires paid license";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/idea/ideaIU-${version}.tar.gz";
      sha256 = "10zv3m44ci7gl7163yp4wxnjy7c0g5zl34c2ibnx4c6ds6l4di2p";
    };
  };

  ruby-mine = buildRubyMine rec {
    name = "ruby-mine-${version}";
    version = "7.0.4";
    build = "139.1231";
    description = "The Most Intelligent Ruby and Rails IDE";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/ruby/RubyMine-${version}.tar.gz";
      sha256 = "08b0iwccb5w9b1yk0kbs99r5mxkcyxqs9mkr57wb5j71an80yx38";
    };
  };

  pycharm-community = buildPycharm rec {
    name = "pycharm-community-${version}";
    version = "4.0.5";
    build = "139.1547";
    description = "PyCharm 4.0 Community Edition";
    license = stdenv.lib.licenses.asl20;
    src = fetchurl {
      url = "https://download.jetbrains.com/python/${name}.tar.gz";
      sha256 = "16na04sp9q7z10kjx8wpf9k9bv9vgv7rmd9jnrn72nhwd7bp0n1i";
    };
  };

  pycharm-professional = buildPycharm rec {
    name = "pycharm-professional-${version}";
    version = "4.0.5";
    build = "139.1547";
    description = "PyCharm 4.0 Professional Edition";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/python/${name}.tar.gz";
      sha256 = "17cxznv7q47isym6l7kbp3jdzdgj02jayygy42x4bwjmg579v1gg";
    };
  };

  phpstorm = buildPhpStorm rec {
    name = "phpstorm-${version}";
    version = "8.0.3";
    build = "PS-139.1348";
    description = "Professional IDE for Web and PHP developers";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/webide/PhpStorm-${version}.tar.gz";
      sha256 = "1x67nfr3nap93cx7yhdrp02xvp1v6g74zy7hdmhx41sal7hzy49b";
    };
  };

}
