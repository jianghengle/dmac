<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Confirm</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body modal-body">
            <div>{{message}}</div>
        </section>
        <footer class="modal-card-foot">
          <a class="button is-danger" @click="confirm">Yes, I am sure</a>
          <a class="button" @click="close">Cancel</a>
        </footer>
      </div>
    </div>
</template>

<script>
export default {
    name: 'confirm-modal',
    props: ['opened', 'message'],
    methods: {
        close(){
            this.$emit('close-confirm-modal', false)
        },
        confirm(){
            this.$emit('close-confirm-modal', true)
        }
    },
}
</script>

<style lang="scss" scoped>

.modal-body {
    color: black;
    font-size: 16px;
}
</style>