# RebuildQueueRunner - run RebuildQueue periodically
#
# $Id$
#
# This software is provided as-is. You may use it for commercial or 
# personal use. If you distribute it, please keep this notice intact.
#
# Copyright (c) 2007 Hirotaka Ogawa

package MT::Plugin::RebuildQueueRunner;
use strict;
use MT;
use base 'MT::Plugin';
use File::Spec;

our $REBUILD_QUEUE = File::Spec->catfile(MT->instance->mt_dir, 'plugins', 'RebuildQueue', 'RebuildQueue.pl');
our $VERSION = '0.01';

my $plugin = __PACKAGE__->new({
    name => 'RebuildQueueRunner',
    description => 'A plugin for running RebuildQueue periodically.',
    doc_link => 'http://code.as-is.net/wiki/RebuildQueueRunner_Plugin',
    author_name => 'Hirotaka Ogawa',
    author_link => 'http://profile.typekey.com/ogawa/',
    version => $VERSION,
    callbacks => {
	'BuildFileFilter' => {
	    priority  => 10,
	    code      => sub { MT->run_tasks('RebuildQueueRunner') },
	},
    },
    tasks => {
	'RebuildQueueRunner' => {
	    name      => "RebuildQueueRunner (every 5 minutes)",
	    frequency => 10,
	    code      => \&rebuild_queue_runner,
	},
    },
    settings => new MT::PluginSettings([
	['rebuild_queue_args', { Default => '--load=50' }],
    ]),
    system_config_template => 'RebuildQueueRunner.tmpl',
});
MT->add_plugin($plugin);

sub rebuild_queue_runner {
    $| = 1;
    my $pid = fork();
    if (!$pid) {
	print STDERR "Run RebuildQueue\n";
	close STDIN ; open STDIN , "</dev/null";
	close STDOUT; open STDOUT, ">/dev/null";
	close STDERR; open STDERR, ">/dev/null";
	exec $REBUILD_QUEUE, $plugin->get_config_value('rebuild_queue_args');
	CORE::exit(0);
    }
}

1;
