### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 494060d1-a489-4514-ab37-cf729f39765b
using PlutoUI

# ╔═╡ acaa73da-b532-11ee-2182-33a02f8ac82d
using MusicTheory

# ╔═╡ 4b6be554-a27b-4573-9b11-2ca0556e42fb
using HypertextLiteral

# ╔═╡ 739fc12a-1f78-4eaf-8a62-834f90ea96ba
using MusicTheory.PitchNames

# ╔═╡ 24cca7b9-7a33-415e-b73b-93bebd224b93
md"""
# Play a note!

Re-run this cell to hear the note :)
"""

# ╔═╡ 2fbd22e2-655a-4825-9b50-f05505d09458
md"""
# With a slider!
"""

# ╔═╡ 7c381193-0ba7-499c-953f-b7b0c3fc4f1c


# ╔═╡ f2b1788d-9a17-4daf-b333-65a961761e76


# ╔═╡ 77ebbeaa-b53b-41c5-9a8c-b8c3afec33fc


# ╔═╡ f9b088ed-7109-4fc8-8a93-990ed47111fd
scale = Scale(C[4], major_scale)

# ╔═╡ 8f1d2964-dac6-4752-8bb9-3267cbc1a126
scale_tones = Base.Iterators.take(scale, 22) |> collect

# ╔═╡ 75b4abd4-ab3d-40ef-860f-1c5efa36bf92
@bind scale_test Slider(scale_tones; show_value=true)

# ╔═╡ 436b58b9-4bdc-42b1-8d26-b99151b1ceea
scale_test

# ╔═╡ b5177976-2ee3-4085-831d-ec6348df6f0f
md"""
# Derp
"""

# ╔═╡ 945164df-120e-445f-b469-71a9d29328dc
C♯

# ╔═╡ 00ba0791-ff00-4eb6-8603-d228d33e46a7
note = C♯[5] / 4

# ╔═╡ c5b564ab-f905-4210-9e1e-1432351cc3aa
C♯ |> typeof

# ╔═╡ 1558212a-c05b-47b5-95dc-12afa241c43c
note.pitch |> dump

# ╔═╡ d7ddb5a2-86bb-4d79-9273-d8ab85a1687a
const frequency_octave_4 = Dict(
	C => 261.626,
	C♯ => 277.183,
	D♭ => 277.183,
	D => 293.665,
	D♯ => 311.127,
	E♭ => 311.127,
	E => 329.628,
	F => 349.228,
	F♯ => 369.994,
	G♭ => 369.994,
	G => 391.995,
	G♯ => 415.305,
	A♭ => 415.305,
	A => 440,
	A♯ => 466.164,
	B♭ => 466.164,
	B => 493.883,
)

# ╔═╡ 1221258a-4f55-4b1c-a6d3-326d9de03468
function frequency(pitch::Pitch)
	freq_at_4 = frequency_octave_4[pitch.class]
	transposition = pitch.octave - 4

	freq_at_4 * (2.0 ^ transposition)
end

# ╔═╡ d247d635-720f-4144-bcb4-fcd49e42e119
md"""
Two notes at the same time:
"""

# ╔═╡ 4a583fa5-83f3-4989-b017-599f152274c1
md"""
# JS implementation
"""

# ╔═╡ c2e18b24-4762-4373-959a-9bef0bc1c044
function play_audio_snippet_nice(pitch::Pitch, duration_seconds::Union{Real,Nothing}=nothing)
	@htl """
	<script>
	const derp = $(rand());

	const Tone = await import("https://esm.sh/tone@14.7.77");

	const synth = new Tone.Synth().toDestination();
	synth.triggerAttackRelease($(frequency(pitch)), $(something(duration_seconds,"8n")));
	invalidation.then(() => {
		// 1 second grace period
		setTimeout(() => {
	
			synth.dispose()
		}, 1000)
	})
	</script>
	"""
end

# ╔═╡ 64d7cd44-21cb-42c3-9817-4511c22c81be
const play = play_audio_snippet_nice

# ╔═╡ ea609ec1-583a-4f13-b908-858defc44a36
play(E♭[5])

# ╔═╡ 380c2e3f-1082-438e-a598-f752cadf87c2
play(scale_test)

# ╔═╡ c47816b4-6129-47dc-b81c-a01db3bee463
[
	play(C[4], 2),
	play(G[4], 2)
]

# ╔═╡ ca21c388-0de0-48a7-a622-e259f3410764
function play_audio_snippet_old(pitch::Pitch, duration_seconds::Real)
	@htl """
	<script>
	const derp = $(rand());
	// create web audio api context
	const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
	
	// create Oscillator node
	const oscillator = audioCtx.createOscillator();
	const gain = audioCtx.createGain();
	
	oscillator.type = "sine";
	oscillator.frequency.setValueAtTime($(frequency(pitch)), audioCtx.currentTime); 
	gain.gain.value = .5;
	oscillator.connect(audioCtx.destination);
	oscillator.start();
	invalidation.then(() => {
		oscillator.stop()
	})
	setTimeout(() => {
		oscillator.stop()
	}, $(duration_seconds) * 1000)
	</script>
	"""
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
MusicTheory = "564e61e1-4667-41b2-a4a2-754a0240c775"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.5"
MusicTheory = "~0.1.0"
PlutoUI = "~0.7.55"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0"
manifest_format = "2.0"
project_hash = "8162ec54e46fa61eb02618abb7da6cc4cbda672b"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "c278dfab760520b8bb7e9511b968bf4ba38b7acc"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.MusicTheory]]
git-tree-sha1 = "38036eb7d62d3fa0d4bf4ee90af15f5f7c0d55b2"
uuid = "564e61e1-4667-41b2-a4a2-754a0240c775"
version = "0.1.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "68723afdb616445c6caaef6255067a8339f91325"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.55"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─24cca7b9-7a33-415e-b73b-93bebd224b93
# ╠═ea609ec1-583a-4f13-b908-858defc44a36
# ╟─2fbd22e2-655a-4825-9b50-f05505d09458
# ╠═75b4abd4-ab3d-40ef-860f-1c5efa36bf92
# ╠═436b58b9-4bdc-42b1-8d26-b99151b1ceea
# ╠═380c2e3f-1082-438e-a598-f752cadf87c2
# ╟─7c381193-0ba7-499c-953f-b7b0c3fc4f1c
# ╟─f2b1788d-9a17-4daf-b333-65a961761e76
# ╟─77ebbeaa-b53b-41c5-9a8c-b8c3afec33fc
# ╠═f9b088ed-7109-4fc8-8a93-990ed47111fd
# ╠═8f1d2964-dac6-4752-8bb9-3267cbc1a126
# ╟─b5177976-2ee3-4085-831d-ec6348df6f0f
# ╠═494060d1-a489-4514-ab37-cf729f39765b
# ╠═acaa73da-b532-11ee-2182-33a02f8ac82d
# ╠═4b6be554-a27b-4573-9b11-2ca0556e42fb
# ╠═739fc12a-1f78-4eaf-8a62-834f90ea96ba
# ╠═945164df-120e-445f-b469-71a9d29328dc
# ╠═00ba0791-ff00-4eb6-8603-d228d33e46a7
# ╠═c5b564ab-f905-4210-9e1e-1432351cc3aa
# ╠═1558212a-c05b-47b5-95dc-12afa241c43c
# ╠═d7ddb5a2-86bb-4d79-9273-d8ab85a1687a
# ╠═1221258a-4f55-4b1c-a6d3-326d9de03468
# ╟─d247d635-720f-4144-bcb4-fcd49e42e119
# ╠═c47816b4-6129-47dc-b81c-a01db3bee463
# ╟─4a583fa5-83f3-4989-b017-599f152274c1
# ╟─64d7cd44-21cb-42c3-9817-4511c22c81be
# ╠═c2e18b24-4762-4373-959a-9bef0bc1c044
# ╟─ca21c388-0de0-48a7-a622-e259f3410764
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
