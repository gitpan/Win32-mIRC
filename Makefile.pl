use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Win32::mIRC',
    VERSION_FROM => 'mIRC.pm', # finds $VERSION
    AUTHOR       => 'Matthew Musgrove (muskrat@mindless.com)',
    ABSTRACT     => 'Win32::mIRC',
);
