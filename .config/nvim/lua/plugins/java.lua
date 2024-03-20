return {
	{
		"mfussenegger/nvim-jdtls",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		ft = "java",
		opts = {
			root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
		},
		config = function(_, opts)
			local resolve_opts = function()
				local Path = require("plenary.path")
				local root_dir = require("jdtls.setup").find_root(opts.root_markers)
				local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
				local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace-root/" .. project_name
				if vim.loop.fs_stat(workspace_dir) == nil then
					Path:new(workspace_dir):mkdir({ parents = true })
				end
				local jdtls_path = require("mason-registry").get_package("jdtls"):get_install_path()
				local java_debug_path = require("mason-registry").get_package("java-debug-adapter"):get_install_path()
				local java_test_path = require("mason-registry").get_package("java-test"):get_install_path()
				local os
				if vim.fn.has("macunix") then
					os = "mac"
				else
					os = "linux"
				end

				local bundles = {
					vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
				}
				vim.list_extend(
					bundles,
					vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n")
				)

				return {
					cmd = {
						"java",
						"-Declipse.application=org.eclipse.jdt.ls.core.id1",
						"-Dosgi.bundles.defaultStartLevel=4",
						"-Declipse.product=org.eclipse.jdt.ls.core.product",
						"-Dlog.protocol=true",
						"-Dlog.level=ALL",
						"-javaagent:" .. jdtls_path .. "/lombok.jar",
						"-Xmx1g",
						"--add-modules=ALL-SYSTEM",
						"--add-opens",
						"java.base/java.util=ALL-UNNAMED",
						"--add-opens",
						"java.base/java.lang=ALL-UNNAMED",
						"-jar",
						vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
						"-configuration",
						jdtls_path .. "/config_" .. os,
						"-data",
						workspace_dir,
					},
					root_dir = root_dir,
					init_options = {
						bundles = bundles,
					},
				}
			end
			vim.api.nvim_create_autocmd("Filetype", {
				pattern = "java",
				callback = function()
					require("jdtls").start_or_attach(resolve_opts())
				end,
			})
		end,
	},
}
