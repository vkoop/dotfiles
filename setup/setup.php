<?php

// SETUP script

require 'vendor/autoload.php';

namespace vkoop\dotfiles\Setup;

use Symfony\Component\Console\Application;
use Symfony\Component\Console\Command\Command;

class SetupInstallCommand extends Command {

	protected function configure() {
		$this->setName("setup")
				->setDescription("create symlinks");
	}

	protected function execute(\Symfony\Component\Console\Input\InputInterface $input, \Symfony\Component\Console\Output\OutputInterface $output) {
		$linkables = glob('**/*{.symlink}');

		$skip_all = false;
		$overwrite_all = false;
		$backup_all = false;

		foreach ($linkables as $linkable) {
			$overwrite = false;
			$backup = false;

			$file = array_pop(explode("/", $linkable));
			$file = array_pop(explode(".symlink", $file));

			$home = getenv("HOME");
			$target = sprintf("%s/.%s ", $home, $file);

			if (file_exists($target)) {
				if (!$skip_all && !$overwrite_all && !$backup_all) {
					$dialog = $this->getHelperSet()->get('dialog');

					$option = $dialog->ask($output, "File already exists: #{target}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all");
					switch ($option) {
						case "o":
							$overwrite = true;
							break;
						case "b":
							$backup = true;
							break;
						case "O":
							$overwrite_all = true;
							break;
						case "B":
							$backup_all = true;
							break;
						case "S":
							$skip_all = true;
							break;
						case "s":
							continue;
					}
				}
				
				if($overwrite || $overwrite_all){
					if(is_file($target)) unlink ($target);
					else{
						//delete recursive
						$iter =new \RecursiveIteratorIterator(
								new \DirectoryIterator($target),
								\RecursiveIteratorIterator::CHILD_FIRST
						);
						foreach($iter as $f){
							if(is_file($f)) unlink ($f);
							else rmdir ($f);
						}
					}
				}
				if($backup || $backup_all){
					exec(sprintf("mv '$home/.$file' '$home/.$file.backup'"));
				}
			}
			exec(sprintf("ln -s '%s' '$target'", realpath($linkable)));
		}
	}

}


$application = new Application();
$application->add(new SetupInstallCommand());
$application->run();