<?php

namespace vkoop\dotfiles\Setup;

require 'vendor/autoload.php';

use Symfony\Component\Console\Application;
use Symfony\Component\Console\Command\Command;

class SetupInstallCommand extends Command {

	protected function configure() {
		$this->setName("setup")
				->setDescription("create symlinks");
	}

	private function deleteRecursive($target) {
		$iter = new \RecursiveIteratorIterator(
				new \RecursiveDirectoryIterator($target), \RecursiveIteratorIterator::CHILD_FIRST
		);
		foreach ($iter as $f) {
			if ($f->isFile())
				unlink($f->__toString());
			else
				rmdir($f->__toString());
		}
	}

	protected function execute(\Symfony\Component\Console\Input\InputInterface $input, \Symfony\Component\Console\Output\OutputInterface $output) {
		$output->writeln('<info>Start setup</info>');
		$path = realpath(__DIR__."/..");
		$output->writeln("<info>Path: $path</info>");

		$linkables = new SymlinkFilterIterator( new \RecursiveIteratorIterator(
				new \RecursiveDirectoryIterator($path) , \RecursiveIteratorIterator::SELF_FIRST
		));

		$skip_all = false;
		$overwrite_all = false;
		$backup_all = false;

		foreach ($linkables as $linkableFile) {
			$linkable = $linkableFile->__toString();
			$output->writeln("<info>Found file to link: $linkable</info>");
			$overwrite = false;
			$backup = false;

			$file = array_pop(array_filter(explode("/", $linkable)));
			$file = array_pop(array_filter(explode(".symlink", $file)));

			$home = getenv("HOME");
			$target = sprintf("%s/.%s ", $home, $file);

			if (file_exists($target)) {
				if (!$skip_all && !$overwrite_all && !$backup_all) {
					$dialog = $this->getHelperSet()->get('dialog');

					$option = $dialog->ask($output, "File already exists: $target, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all");
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
							break 2;
						case "s":
							continue 2;
					}
				}

				if ($overwrite || $overwrite_all) {
					if (is_file($target))
						unlink($target);
					else {
						$this->deleteRecursive($target);
					}
				}
				if ($backup || $backup_all) {
					exec(sprintf("mv '$home/.$file' '$home/.$file.backup'"));
				}
			}
			exec(sprintf("ln -s '%s' '$target'", realpath($linkable)));
		}
	}

}

class SymlinkFilterIterator extends \FilterIterator{
	public function accept() {
		if (array_pop(explode(".", parent::current()->__toString())) == "symlink")
			return TRUE;
		else return FALSE;
	}	
}

$application = new Application();
$application->add(new SetupInstallCommand());
$application->run();
