import Vue from 'vue'
import { mapGetters, mapActions } from 'vuex'

Vue.mixin({
	computed: {
		...mapGetters({
			auth: 'userData'
		})
	}
})